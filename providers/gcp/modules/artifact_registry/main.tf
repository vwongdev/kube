resource "google_artifact_registry_repository" "kube_repository" {
  location      = var.region
  repository_id = var.repository_name
  format        = "DOCKER"

  cleanup_policy_dry_run = false

  # Keep policies take precedence, so everything outside the most recent images is deleted
  cleanup_policies {
    id     = "delete-all"
    action = "DELETE"
    condition {
      tag_state = "ANY"
    }
  }

  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"
    most_recent_versions {
      keep_count = var.max_image_count
    }
  }
}
