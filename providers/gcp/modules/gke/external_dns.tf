resource "google_project_iam_member" "external_dns" {
  project = data.google_project.current.project_id
  role    = "roles/dns.admin"
  member  = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_container_cluster.main.workload_identity_config[0].workload_pool}/subject/ns/external-dns/sa/external-dns"
}
