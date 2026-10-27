variable "region" {
  type = string
}

variable "repository_name" {
  type        = string
  description = "Name of the Artifact Registry repository"
  default     = "kube"
}

variable "max_image_count" {
  type        = number
  description = "Maximum number of images to keep"
  default     = 10
}
