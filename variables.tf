variable "project_id" {
  description = "GCP project ID to deploy the Wheelers landing page into."
  type        = string
}

variable "region" {
  description = "GCP region for all resources."
  type        = string
}

variable "domain" {
  description = "Custom domain the landing page will be served on (e.g. wheele.rs). Used for the shared load balancer's host routing -- this repo does not manage DNS itself, see terraform.infrastructure's backends variable."
  type        = string
}

variable "image_tag" {
  description = "Tag of the ghcr.io/its-me/wheelers.landing image to deploy (set by that repo's release workflow, e.g. a version tag without the 'v' prefix)."
  type        = string
  default     = "latest"
}

variable "server_cpu" {
  description = "vCPUs allocated to the Cloud Run container. Must be >= 1: below that, Cloud Run silently caps max_instance_request_concurrency at 1 (vs. 80 for cpu >= 1), which limits the whole instance to one in-flight request at a time."
  type        = string
  default     = "1"
}

variable "server_memory" {
  description = "Memory allocated to the Cloud Run container."
  type        = string
  default     = "512Mi"
}

variable "server_min_instance_count" {
  description = "Minimum number of instances. 0 allows scale-to-zero when idle (a static marketing site with no persistent connections has nothing to lose from a cold start on the next request)."
  type        = number
  default     = 0
}

variable "server_max_instance_count" {
  description = "Maximum number of instances."
  type        = number
  default     = 2
}

variable "smtp_env" {
  description = "SMTP settings for the contact form (SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, SMTP_START_TLS, SMTP_USE_TLS, MAIL_FROM, CONTACT_TO -- see that repo's .env.example). Optional -- if SMTP_HOST is unset, submissions are accepted and logged but not emailed. Each entry is stored as its own Secret Manager secret and exposed to the container under the given env var name."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "labels" {
  description = "Labels applied to all resources that support them."
  type        = map(string)
  default = {
    app        = "landing"
    managed-by = "terraform"
  }
}
