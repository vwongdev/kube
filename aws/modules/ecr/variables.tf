variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
  default     = "kube"
}

variable "scan_on_push" {
  type        = bool
  description = "Enable image scanning on push"
  default     = true
}

variable "max_image_count" {
  type        = number
  description = "Maximum number of images to keep"
  default     = 10
}

