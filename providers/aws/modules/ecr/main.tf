locals {
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository" "kube_repository" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "kube_repository_lifecycle_policy" {
  repository = aws_ecr_repository.kube_repository.name
  policy     = local.lifecycle_policy
}

# Applies to repositories that organisation repositories create on first push
resource "aws_ecr_repository_creation_template" "default" {
  prefix               = "ROOT"
  description          = "Repositories created on first push"
  applied_for          = ["CREATE_ON_PUSH"]
  image_tag_mutability = "MUTABLE"
  lifecycle_policy     = local.lifecycle_policy

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Creation templates cannot set scanning, so scan on push across the registry
resource "aws_ecr_registry_scanning_configuration" "registry" {
  scan_type = "BASIC"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}
