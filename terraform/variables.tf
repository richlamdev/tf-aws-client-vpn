variable "aws_client_vpn_port" {
  default = 443
}

variable "aws_client_vpn_protocol" {
  default = "udp"
}

variable "private_subnet_ssh_port" {
  default = 22
}

variable "private_subnet_ssh_protocol" {
  default = "tcp"
}

variable "private_subnet_list" {
  default = ["10.0.2.0/24"]
}

variable "vpn_client_cidr_block" {
  default = "10.5.0.0/20"
}

variable "vpn_client_protocol" {
  default = "udp"
}

##############

provider "aws" {
  region  = var.region
  profile = "cloud_user"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "default_tags" {
  type        = map(any)
  description = "Map of Default Tags"
}

variable "public_subnet" {
  default = "10.0.1.0/24"
}

variable "private_subnet" {
  default = "10.0.2.0/24"
}
