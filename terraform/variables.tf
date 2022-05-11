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

variable "egress_all_cidr_blocks" {
  default = "0.0.0.0/0"
}

variable "egress_all_cidr_all_block_list" {
  default = ["0.0.0.0/0"]
}

variable "vpn_client_cidr_block" {
  default = "10.5.0.0/20"
}

variable "vpn_client_protocol" {
  default = "udp"
}

variable "egress_all_default_port" {
  default = 0
  description = "This port number should always be used if the protocol is '-1 (all)'"
}

variable "egress_all_protocol" {
  default = "-1"
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
