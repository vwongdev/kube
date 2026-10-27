# Creates resources to bootstrap a new Google Cloud project for Terraform management.
# Deployed via Infrastructure Manager, which must be set up manually outside CI/CD for the first time!
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.8.1"
    }
  }
}

provider "google" {
  project = var.project
}

resource "google_project_service" "services" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "dns.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"

  depends_on = [google_project_service.services]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = "assertion.sub.startsWith('repo:${var.org_name}/${var.repo_name}:environment:')"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "primary_pipeline" {
  account_id = "primary-pipeline"

  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "primary_pipeline" {
  project = var.project
  role    = "roles/owner"
  member  = google_service_account.primary_pipeline.member
}

resource "google_service_account_iam_member" "primary_pipeline_workload_identity" {
  service_account_id = google_service_account.primary_pipeline.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.org_name}/${var.repo_name}"
}

resource "google_storage_bucket" "terraform_state" {
  name                        = "tf-state-bucket-${var.project}"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
