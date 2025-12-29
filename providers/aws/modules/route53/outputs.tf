output "zone_id" {
  value       = aws_route53_zone.hosted_zone.zone_id
  description = "Hosted Zone ID"
}

output "zone_name" {
  value       = aws_route53_zone.hosted_zone.name
  description = "Hosted Zone name"
}

output "name_servers" {
  value       = aws_route53_zone.hosted_zone.name_servers
  description = "Name servers (list) for DNS delegation"
}