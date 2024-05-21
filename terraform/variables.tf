variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "172.31.0.0/24"
}

variable "az_count" {
    description = "Number of AZs to cover in a given region"
    default = "2"
}