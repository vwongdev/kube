terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.100.0"
        }
        tls = {
            source = "hashicorp/tls"
            version = "~> 4.0"
        }
    }
    backend "s3" {}
}

provider "aws" {
    region  = var.region
}

module "vpc" {
    source  = "./modules/vpc"
    region = var.region
}

module "eks" {
    source  = "./modules/eks"
    subnet_ids = module.vpc.private_subnet_ids
}

module "ecr" {
    source = "./modules/ecr"
}

module "route53" {
    source = "./modules/route53"
    domain = var.domain
}