output "route53_name_servers" {
  value       = module.route53.name_servers
  description = "Route53 name servers (list) for DNS delegation"
}