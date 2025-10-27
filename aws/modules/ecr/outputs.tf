output "repository_url" {
  value       = aws_ecr_repository.kube_repository.repository_url
  description = "URL of the ECR repository"
}

output "repository_arn" {
  value       = aws_ecr_repository.kube_repository.arn
  description = "ARN of the ECR repository"
}

output "repository_name" {
  value       = aws_ecr_repository.kube_repository.name
  description = "Name of the ECR repository"
}

