output "route53_name_servers" {
  value       = module.route53.name_servers
  description = "Route53 name servers (list) for DNS delegation"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster"
}