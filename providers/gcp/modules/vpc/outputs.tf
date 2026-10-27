output "network_id" {
  value = google_compute_network.main.id
}

output "subnet_id" {
  value = google_compute_subnetwork.private.id
}

output "pods_range_name" {
  value = google_compute_subnetwork.private.secondary_ip_range[0].range_name
}

output "services_range_name" {
  value = google_compute_subnetwork.private.secondary_ip_range[1].range_name
}
