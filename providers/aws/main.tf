terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source       = "./modules/vpc"
  region       = var.region
  cluster_name = var.cluster_name
}

module "eks" {
  source       = "./modules/eks"
  subnet_ids   = module.vpc.private_subnet_ids
  cluster_name = var.cluster_name
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
}

module "route53" {
  source = "./modules/route53"
  domain = var.domain
}