resource "aws_acm_certificate" "vpn_client_root" {
  private_key       = file("certs/client1.domain.tld.key")
  certificate_body  = file("certs/client1.domain.tld.crt")
  certificate_chain = file("certs/ca.crt")

  tags = var.default_tags
}


resource "aws_acm_certificate" "vpn_server_root" {
  private_key       = file("certs/server.key")
  certificate_body  = file("certs/server.crt")
  certificate_chain = file("certs/ca.crt")

  tags = var.default_tags
}


resource "aws_acm_certificate" "vpn_server" {
  domain_name = "example-vpn.example.com"
  validation_method = "DNS"

  #tags = local.global_tags

  #lifecycle {
  #  create_before_destroy = true
  #}
}

#resource "aws_acm_certificate_validation" "vpn_server" {
  #certificate_arn = aws_acm_certificate.vpn_server.arn
#
  #timeouts {
    #create = "15m"
  #}
#}


resource "aws_security_group" "vpn_access" {
  vpc_id = aws_vpc.main.id
  name = "vpn-example-sg"

  ingress {
    from_port = 443
    protocol = "UDP"
    to_port = 443
    cidr_blocks = [
      "0.0.0.0/0"]
    description = "Incoming VPN connection"
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  #tags = local.global_tags
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description = "Client VPN example"
  client_cidr_block = "10.20.0.0/22"
  server_certificate_arn = aws_acm_certificate.vpn_client_root.arn

  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_server_root.arn
  }

  connection_log_options {
    enabled = false
  }

  vpc_id = aws_vpc.main.id
  split_tunnel = true
  transport_protocol = "udp"

  security_group_ids = [aws_security_group.private_ssh.id, aws_security_group.icmp.id]
  #tags = local.global_tags

}

resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  #count = length(aws_subnet.private.id)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id = aws_subnet.private.id
  security_groups = [aws_security_group.vpn_access.id]

  lifecycle {
    // The issue why we are ignoring changes is that on every change
    // terraform screws up most of the vpn assosciations
    // see: https://github.com/hashicorp/terraform-provider-aws/issues/14717
    ignore_changes = [subnet_id]
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr = aws_vpc.main.cidr_block
  authorize_all_groups = true
}
