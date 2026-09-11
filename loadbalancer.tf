# Owns the pieces of the shared load balancer that are specific to this app (regional
# serverless NEG + backend service pointing at its own Cloud Run service), so this repo
# can be applied/destroyed independently. The URL map host rule and the managed SSL
# certificate's domain list are still owned by terraform.infrastructure (GCP only
# allows one Terraform-managed owner for each of those), which references the backend
# service created here by ID -- see that repo's backends variable (backend_service_id).
resource "google_compute_region_network_endpoint_group" "server" {
  name                  = "landing-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.server.name
  }
}

resource "google_compute_backend_service" "server" {
  name                  = "landing-backend"
  project               = var.project_id
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.server.id
  }

  depends_on = [google_project_service.apis]
}
