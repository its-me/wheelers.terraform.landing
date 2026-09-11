# var.smtp_env is sensitive, so its keys are pulled out via nonsensitive() for use as
# for_each identifiers (Terraform forbids sensitive values there); the credential values
# themselves stay sensitive throughout.
locals {
  smtp_env_keys = nonsensitive(toset(keys(var.smtp_env)))
}

resource "google_secret_manager_secret" "smtp" {
  for_each = local.smtp_env_keys

  project   = var.project_id
  secret_id = "landing-smtp-${lower(replace(each.value, "_", "-"))}"
  labels    = var.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "smtp" {
  for_each = local.smtp_env_keys

  secret      = google_secret_manager_secret.smtp[each.value].id
  secret_data = var.smtp_env[each.value]
}
