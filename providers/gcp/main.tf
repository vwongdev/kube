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

module "vpc" {
  source       = "./modules/vpc"
  region       = var.region
  cluster_name = var.cluster_name
}

module "gke" {
  source              = "./modules/gke"
  zone                = var.zone
  cluster_name        = var.cluster_name
  network_id          = module.vpc.network_id
  subnet_id           = module.vpc.subnet_id
  pods_range_name     = module.vpc.pods_range_name
  services_range_name = module.vpc.services_range_name
  admin_email         = var.admin_email
}

module "artifact_registry" {
  source          = "./modules/artifact_registry"
  region          = var.region
  repository_name = var.repository_name
}

module "dns" {
  source = "./modules/dns"
  domain = var.domain
}
