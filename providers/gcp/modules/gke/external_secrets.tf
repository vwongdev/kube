resource "google_project_iam_member" "external_secrets" {
  project = data.google_project.current.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_container_cluster.main.workload_identity_config[0].workload_pool}/subject/ns/external-secrets/sa/external-secrets"
}
