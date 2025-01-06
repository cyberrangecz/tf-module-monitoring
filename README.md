<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.prometheus_stack](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map.icmpexporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.network](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.nodeexporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.windowsexporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_manifest.prometheus_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.prometheus_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.prometheus](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [http_http.openid_configuration](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_credential_id"></a> [application\_credential\_id](#input\_application\_credential\_id) | Application credentials ID for accessing OpenStack project | `string` | n/a | yes |
| <a name="input_application_credential_secret"></a> [application\_credential\_secret](#input\_application\_credential\_secret) | Application credentials secret for accessing OpenStack project | `string` | n/a | yes |
| <a name="input_grafana_default_dashboards_enabled"></a> [grafana\_default\_dashboards\_enabled](#input\_grafana\_default\_dashboards\_enabled) | Install default dashboards | `bool` | `true` | no |
| <a name="input_grafana_login_maximum_inactive_lifetime_duration"></a> [grafana\_login\_maximum\_inactive\_lifetime\_duration](#input\_grafana\_login\_maximum\_inactive\_lifetime\_duration) | Grafana login\_maximum\_inactive\_lifetime\_duration | `string` | `"7d"` | no |
| <a name="input_grafana_login_maximum_lifetime_duration"></a> [grafana\_login\_maximum\_lifetime\_duration](#input\_grafana\_login\_maximum\_lifetime\_duration) | Grafana login\_maximum\_lifetime\_duration | `string` | `"30d"` | no |
| <a name="input_grafana_oidc_provider"></a> [grafana\_oidc\_provider](#input\_grafana\_oidc\_provider) | OIDC provider for OAUTH2 authentication | <pre>object({<br/>    url          = string<br/>    clientId     = string<br/>    clientSecret = string<br/>    }<br/>  )</pre> | n/a | yes |
| <a name="input_grafana_token_rotation_interval_minutes"></a> [grafana\_token\_rotation\_interval\_minutes](#input\_grafana\_token\_rotation\_interval\_minutes) | Grafana token\_rotation\_interval\_minutes | `string` | `"10"` | no |
| <a name="input_head_host"></a> [head\_host](#input\_head\_host) | FQDN/IP address of node/LB, where head services are running | `string` | n/a | yes |
| <a name="input_openid_configuration_insecure"></a> [openid\_configuration\_insecure](#input\_openid\_configuration\_insecure) | n/a | `bool` | `false` | no |
| <a name="input_os_auth_url"></a> [os\_auth\_url](#input\_os\_auth\_url) | OpenStack authentication URL | `string` | n/a | yes |
| <a name="input_os_region"></a> [os\_region](#input\_os\_region) | OpenStack region | `string` | n/a | yes |
| <a name="input_value_file"></a> [value\_file](#input\_value\_file) | File containing prometheus jobs | `string` | `"values-prometheus-jobs.yaml"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | Password for Prometheus and Grafana admin users |
<!-- END_TF_DOCS -->
