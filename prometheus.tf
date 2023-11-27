resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "random_password" "password" {
  length  = 20
  special = false
}

resource "kubernetes_manifest" "prometheus_secret" {
  computed_fields = ["data"]
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Secret"
    "metadata" = {
      "name"      = "prometheus-secret"
      "namespace" = "prometheus"
    }
    "type" = "Opaque"
    "data" = {
      "auth" = "${base64encode("admin:${random_password.password.bcrypt_hash}")}"
    }
  }
  depends_on = [
    kubernetes_namespace.prometheus
  ]
}

resource "kubernetes_manifest" "prometheus_auth" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "prometheus-ingress-auth"
      "namespace" = "prometheus"
    }
    "spec" = {
      "basicAuth" = {
        "secret"       = "prometheus-secret"
        "removeHeader" = true
      }
    }
  }
  depends_on = [
    kubernetes_namespace.prometheus
  ]
}

data "http" "openid_configuration" {
  url      = "${trimsuffix(var.grafana_oidc_provider["url"], "/")}/.well-known/openid-configuration"
  insecure = var.openid_configuration_insecure

  request_headers = {
    Accept = "application/json"
  }
}

resource "helm_release" "prometheus_stack" {
  name             = "prometheus"
  namespace        = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true
  wait             = true

  set {
    name  = "prometheus-node-exporter.hostNetwork"
    value = false
  }

  values = [
    jsonencode(
      {
        alertmanager = {
          ingress = {
            annotations = {
              "traefik.ingress.kubernetes.io/router.middlewares" = "prometheus-prometheus-ingress-auth@kubernetescrd"
            }
            enabled = true
            hosts   = [can(cidrnetmask("${var.head_host}/32")) ? "" : "${var.head_host}"]
            paths   = ["/alerts/"]
          }
          alertmanagerSpec = {
            externalUrl = "https://${var.head_host}/alerts/"
            routePrefix = "/alerts/"
          }
        }
        grafana = {
          adminPassword            = random_password.password.result
          defaultDashboardsEnabled = var.grafana_default_dashboards_enabled
          ingress = {
            enabled = true
            hosts   = [can(cidrnetmask("${var.head_host}/32")) ? "" : "${var.head_host}"]
            path    = "/grafana"
          }
          sidecar = {
            dashboards = {
              folderAnnotation = "grafana_folder"
              provider = {
                foldersFromFilesStructure = true
              }
            }
          }
          "grafana.ini" = {
            server = {
              domain              = var.head_host
              root_url            = "https://%(domain)s/grafana"
              serve_from_sub_path = true
            }
            "auth" = {
              login_maximum_inactive_lifetime_duration = var.grafana_login_maximum_inactive_lifetime_duration
              login_maximum_lifetime_duration          = var.grafana_login_maximum_lifetime_duration
              oauth_allow_insecure_email_lookup        = true
              token_rotation_interval_minutes          = var.grafana_token_rotation_interval_minutes
            }
            "auth.generic_oauth" = {
              enabled       = true
              allow_sign_up = false
              client_id     = var.grafana_oidc_provider["clientId"]
              client_secret = var.grafana_oidc_provider["clientSecret"]
              scopes        = "openid email profile"
              use_pkce      = true
              auth_url      = jsondecode(data.http.openid_configuration.response_body)["authorization_endpoint"]
              token_url     = jsondecode(data.http.openid_configuration.response_body)["token_endpoint"]
              api_url       = jsondecode(data.http.openid_configuration.response_body)["userinfo_endpoint"]
            }
            "auth.anonymous" = {
              enabled = false
            }
          }
        }
        prometheus = {
          ingress = {
            annotations = {
              "traefik.ingress.kubernetes.io/router.middlewares" = "prometheus-prometheus-ingress-auth@kubernetescrd"
            }
            enabled = true
            hosts   = [can(cidrnetmask("${var.head_host}/32")) ? "" : "${var.head_host}"]
            paths   = ["/prometheus/"]
          }
          prometheusSpec = {
            externalUrl = "/prometheus/"
            routePrefix = "/prometheus/"
            storageSpec = {
              volumeClaimTemplate = {
                spec = {
                  storageClassName = "local-path"
                  accessModes      = ["ReadWriteOnce"]
                  resources = {
                    requests = {
                      storage = "20Gi"
                    }
                  }
                }
              }
            }
            additionalScrapeConfigs = concat(var.prometheus_jobs, [{
              job_name        = "federation"
              scrape_interval = "15s"
              scrape_timeout  = "15s"
              scheme          = "http"
              honor_labels    = true
              metrics_path    = "/federate"
              params          = { "match[]" = ["{__name__=~\".+\"}"] }
              openstack_sd_configs = [{
                role                          = "instance"
                identity_endpoint             = var.os_auth_url
                region                        = var.os_region
                application_credential_id     = var.application_credential_id
                application_credential_secret = var.application_credential_secret
                port                          = 9090
              }]
              relabel_configs = [
                {
                  source_labels = ["__meta_openstack_address_pool", "__meta_openstack_instance_name"]
                  regex         = "kypo-base-net.*man"
                  action        = "keep"
                }
              ]
            }])
          }
        }
      }
    )
  ]

  depends_on = [
    kubernetes_namespace.prometheus
  ]
}

resource "kubernetes_config_map" "network" {
  metadata {
    name      = "network-availability"
    namespace = "prometheus"
    labels = {
      grafana_dashboard = "1"
    }
    annotations = {
      grafana_folder = "KYPO"
    }
  }

  data = {
    "network-availability.json" = "${file("${path.module}/grafana-dashboards/network-availability.json")}"
  }
  depends_on = [
    kubernetes_namespace.prometheus
  ]
}

resource "kubernetes_config_map" "nodeexporter" {
  metadata {
    name      = "node-exporter"
    namespace = "prometheus"
    labels = {
      grafana_dashboard = "1"
    }
    annotations = {
      grafana_folder = "KYPO"
    }
  }

  data = {
    "node-exporter.json" = "${file("${path.module}/grafana-dashboards/node-exporter.json")}"
  }
  depends_on = [
    kubernetes_namespace.prometheus
  ]
}

resource "kubernetes_config_map" "windowsexporter" {
  metadata {
    name      = "windows-exporter"
    namespace = "prometheus"
    labels = {
      grafana_dashboard = "1"
    }
    annotations = {
      grafana_folder = "KYPO"
    }
  }

  data = {
    "windows-exporter.json" = "${file("${path.module}/grafana-dashboards/windows-exporter.json")}"
  }
  depends_on = [
    kubernetes_namespace.prometheus
  ]
}

resource "kubernetes_config_map" "icmpexporter" {
  metadata {
    name      = "icmp-exporter"
    namespace = "prometheus"
    labels = {
      grafana_dashboard = "1"
    }
    annotations = {
      grafana_folder = "KYPO"
    }
  }

  data = {
    "icmp-exporter.json" = "${file("${path.module}/grafana-dashboards/icmp-exporter.json")}"
  }
  depends_on = [
    kubernetes_namespace.prometheus
  ]
}
