output "cloud_run_url" {
  description = "Auto-generated Cloud Run URL for the server (works immediately, before DNS/SSL cert provisioning finishes)."
  value       = google_cloud_run_v2_service.server.uri
}

output "domain" {
  description = "Custom domain to create a DNS record for. Points at the shared load balancer's IP (see terraform.infrastructure's load_balancer_ip output)."
  value       = var.domain
}

output "backend_service_id" {
  description = "ID of this app's backend service. Paste into terraform.infrastructure's backends variable for this domain's backend_service_id, so the shared load balancer routes to it without this repo needing to live in that repo's module call."
  value       = google_compute_backend_service.server.id
}
