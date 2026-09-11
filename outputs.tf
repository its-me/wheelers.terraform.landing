output "cloud_run_url" {
  description = "Auto-generated Cloud Run URL for the server (works immediately, before DNS/SSL cert provisioning finishes)."
  value       = google_cloud_run_v2_service.server.uri
}

output "domain" {
  description = "Custom domain to create a DNS record for. Points at the shared load balancer's IP (see terraform.infrastructure's load_balancer_ip output)."
  value       = var.domain
}
