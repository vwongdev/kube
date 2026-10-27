output "name_servers" {
  value       = google_dns_managed_zone.hosted_zone.name_servers
  description = "Name servers (list) for DNS delegation"
}
