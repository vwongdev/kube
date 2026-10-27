output "dns_name_servers" {
  value       = module.dns.name_servers
  description = "Cloud DNS name servers (list) for DNS delegation"
}

output "cluster_name" {
  value       = module.gke.cluster_name
  description = "Name of the GKE cluster"
}

output "repository_url" {
  value       = module.artifact_registry.repository_url
  description = "URL of the Artifact Registry repository"
}
