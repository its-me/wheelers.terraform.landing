locals {
  # ghcr.io is directly supported by Cloud Run for public images (this package is
  # public), though GCP caches public ghcr.io images for up to an hour -- if a fresh
  # image_tag doesn't show up immediately after a push, that's why.
  image = "ghcr.io/its-me/wheelers.landing:${var.image_tag}"
}

resource "google_cloud_run_v2_service" "server" {
  name                = "landing"
  project             = var.project_id
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"
  labels              = var.labels

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = var.server_min_instance_count
      max_instance_count = var.server_max_instance_count
    }

    containers {
      name  = "server"
      image = local.image

      ports {
        # Hardcoded: the container's CMD (granian) is started with a fixed --port 8000,
        # not driven by a PORT env var, so there's nothing to make configurable here.
        container_port = 8000
      }

      resources {
        limits = {
          cpu    = var.server_cpu
          memory = var.server_memory
        }
        # GCP requires cpu >= 1 whenever CPU is always allocated (unthrottled). Below
        # that, CPU must be throttled to idle outside of request processing.
        cpu_idle = true
      }

      dynamic "env" {
        for_each = google_secret_manager_secret.smtp
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value.secret_id
              version = "latest"
            }
          }
        }
      }

      startup_probe {
        http_get {
          path = "/"
          port = 8000
        }
        initial_delay_seconds = 5
        period_seconds        = 5
        failure_threshold     = 10
        timeout_seconds       = 5
      }

      liveness_probe {
        http_get {
          path = "/"
          port = 8000
        }
        period_seconds  = 10
        timeout_seconds = 5
      }
    }
  }

  depends_on = [
    google_secret_manager_secret_version.smtp,
  ]
}
