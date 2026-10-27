output "repository_url" {
  value       = "${google_artifact_registry_repository.kube_repository.location}-docker.pkg.dev/${google_artifact_registry_repository.kube_repository.project}/${google_artifact_registry_repository.kube_repository.repository_id}"
  description = "URL of the Artifact Registry repository"
}
