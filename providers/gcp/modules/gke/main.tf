data "google_project" "current" {}

resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.region

  network    = var.network_id
  subnetwork = var.subnet_id

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
  }

  workload_identity_config {
    workload_pool = "${data.google_project.current.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "node_pool" {
  name     = "kube-node-pool"
  cluster  = google_container_cluster.main.id
  location = google_container_cluster.main.location

  # Per zone, so a regional cluster runs three nodes initially
  initial_node_count = 1
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.node_pool.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "google_service_account" "node_pool" {
  account_id = "${var.cluster_name}-nodes"
}

resource "google_project_iam_member" "node_pool" {
  for_each = toset([
    "roles/container.defaultNodeServiceAccount",
    "roles/artifactregistry.reader",
  ])

  project = data.google_project.current.project_id
  role    = each.value
  member  = google_service_account.node_pool.member
}
