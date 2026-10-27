variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EKS"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster, also used to prefix its IAM resources"
}