output "name_servers" {
  value       = google_dns_managed_zone.hosted_zone.name_servers
  description = "Name servers (list) for DNS delegation"
}

output "certificate_name" {
  value       = google_compute_managed_ssl_certificate.cert.name
  description = "Name of the managed SSL certificate, referenced by Ingress"
}
