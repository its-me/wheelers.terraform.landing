resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = "landing-cloud-run"
  display_name = "Wheelers Landing Cloud Run"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_secret_access" {
  for_each = google_secret_manager_secret.smtp

  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Required for the load balancer's serverless NEG to reach this service. Without it,
# GCP's front end rejects every request before it reaches Cloud Run at all (a generic
# "Error: Forbidden" page from "Google Frontend", not an app-level error).
resource "google_cloud_run_v2_service_iam_member" "server_public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.server.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
