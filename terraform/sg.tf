resource "aws_security_group" "vpn_access" {
  vpc_id = aws_vpc.main.id
  name   = "vpn-example-sg"

  ingress {
    from_port = var.aws_client_vpn_port
    to_port   = var.aws_client_vpn_port
    protocol  = var.aws_client_vpn_protocol
    cidr_blocks = var.egress_all_cidr_all_block_list
  }
  egress {
    from_port = var.egress_all_default_port
    to_port   = var.egress_all_default_port
    protocol  = var.egress_all_protocol
    cidr_blocks = var.egress_all_cidr_all_block_list
  }
  tags = var.default_tags
}

resource "aws_security_group" "private_subnet_ssh" {
  name        = "sg_priv_to_priv_ssh"
  description = "allow SSH from within private subnet"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = var.private_subnet_ssh_port
    to_port     = var.private_subnet_ssh_port
    protocol    = var.private_subnet_ssh_protocol
    cidr_blocks = var.private_subnet_list
  }
  egress {
    from_port   = var.egress_all_default_port
    to_port     = var.egress_all_default_port
    protocol    = var.egress_all_protocol
    cidr_blocks = var.egress_all_cidr_all_block_list
  }
  tags = merge(var.default_tags, {
    Name = "private_sg_ssh_only_from_within_private_subnet"
    },
  )
}

resource "aws_security_group" "icmp" {
  name        = "sg_icmp"
  description = "allow icmp within vpc"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = var.egress_all_default_port
    to_port     = var.egress_all_default_port
    protocol    = "icmp"
    cidr_blocks = var.egress_all_cidr_all_block_list
  }
  tags = merge(var.default_tags, {
    Name = "allow icmp within private and public subnet"
    },
  )
}
