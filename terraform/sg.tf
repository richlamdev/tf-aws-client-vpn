resource "aws_security_group" "vpn_access" {
  vpc_id = aws_vpc.main.id
  name   = "vpn-example-sg"

  ingress {
    from_port = var.aws_client_vpn_port
    to_port   = var.aws_client_vpn_port
    protocol  = var.aws_client_vpn_protocol
    cidr_blocks = [
    "0.0.0.0/0"]
    description = "Incoming VPN connection"
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [
    "0.0.0.0/0"]
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, {
    Name = "private_sg_ssh_only_from_within_private_subnet"
    },
  )
}

resource "aws_security_group" "icmp" {
  name        = "sg_icmp"
  description = "allow icmp from public or private subnet"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/20"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, {
    Name = "allow icmp within private and public subnet"
    },
  )
}
