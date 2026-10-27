variable "region" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster, also used to prefix its IAM resources"
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "pods_range_name" {
  type = string
}

variable "services_range_name" {
  type = string
}
