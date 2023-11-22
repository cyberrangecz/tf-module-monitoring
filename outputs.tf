output "admin_password" {
  value       = random_password.password.result
  description = "Password for Prometheus and Grafana admin users"
}
