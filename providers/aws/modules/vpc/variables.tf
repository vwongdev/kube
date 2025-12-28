variable "region" {
    type    = string
    default = "us-east-1"
}

variable "vpc_cidr" {
    type    = string
    default = "10.0.0.0/16"
}

variable "public_subnet_count" {
    type    = number
    default = 2
}

variable "private_subnet_count" {
    type    = number
    default = 2
}