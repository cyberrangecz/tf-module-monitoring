variable "application_credential_id" {
  type        = string
  description = "Application credentials ID for accessing OpenStack project"
}

variable "application_credential_secret" {
  type        = string
  description = "Application credentials secret for accessing OpenStack project"
  sensitive   = true
}

variable "grafana_default_dashboards_enabled" {
  type        = bool
  description = "Install default dashboards"
  default     = true
}

variable "grafana_login_maximum_inactive_lifetime_duration" {
  type        = string
  description = "Grafana login_maximum_inactive_lifetime_duration"
  default     = "7d"
}

variable "grafana_login_maximum_lifetime_duration" {
  type        = string
  description = "Grafana login_maximum_lifetime_duration"
  default     = "30d"
}

variable "grafana_oidc_provider" {
  type = object({
    url          = string
    clientId     = string
    clientSecret = string
    }
  )
  description = "OIDC provider for OAUTH2 authentication"
  sensitive   = true
}

variable "grafana_token_rotation_interval_minutes" {
  type        = string
  description = "Grafana token_rotation_interval_minutes"
  default     = "10"
}

variable "head_host" {
  type        = string
  description = "FQDN/IP address of node/LB, where head services are running"
}

variable "openid_configuration_insecure" {
  type    = bool
  default = false
}

variable "os_auth_url" {
  type        = string
  description = "OpenStack authentication URL"
}

variable "os_insecure_skip_verify" {
  type        = bool
  default     = false
  description = "Skip TLS verification for OpenStack authentication"
}

variable "os_region" {
  type        = string
  description = "OpenStack region"
}

variable "value_file" {
  type        = string
  description = "File containing prometheus jobs"
  default     = "values-prometheus-jobs.yaml"
}
