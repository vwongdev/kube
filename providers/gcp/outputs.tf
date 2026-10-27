output "cluster_name" {
  value       = module.gke.cluster_name
  description = "Name of the GKE cluster"
}

output "repository_url" {
  value       = module.artifact_registry.repository_url
  description = "URL of the Artifact Registry repository"
}
