terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.8.1"
    }
  }
  backend "gcs" {}
}

provider "google" {
  project = var.project
  region  = var.region
}
