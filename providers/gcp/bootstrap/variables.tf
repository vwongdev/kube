variable "project" {
  type        = string
  description = "ID of the project to bootstrap."
}

variable "region" {
  type        = string
  description = "Region of the Terraform state bucket."
}

variable "org_name" {
  type        = string
  description = "Name of the organization."
}

variable "org_id" {
  type        = string
  description = "ID of the organization."
}

variable "repo_name" {
  type        = string
  description = "Name of the repository."
}

variable "repo_id" {
  type        = string
  description = "ID of the repository."
}
