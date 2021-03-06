#resource "aws_acm_certificate" "vpn_client_root" {
#private_key       = file("certs/client1.domain.tld.key")
#certificate_body  = file("certs/client1.domain.tld.crt")
#certificate_chain = file("certs/ca.crt")
#
#tags = var.default_tags
#}

resource "aws_acm_certificate" "vpn_server_root" {
  private_key       = file("certs/server.key")
  certificate_body  = file("certs/server.crt")
  certificate_chain = file("certs/ca.crt")

  tags = var.default_tags
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "AWS Client VPN"
  client_cidr_block      = var.vpn_client_cidr_block
  server_certificate_arn = aws_acm_certificate.vpn_server_root.arn

  # for cert based auth
  #authentication_options {
  #type                       = "certificate-authentication"
  #root_certificate_chain_arn = aws_acm_certificate.vpn_server_root.arn
  #}

  # for saml 2.0 based auth
  authentication_options {
    type              = var.authentication_options_type
    saml_provider_arn = aws_iam_saml_provider.default.arn
  }

  connection_log_options {
    enabled = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.client_vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.logs.name
  }

  vpc_id              = aws_vpc.main.id
  #dns_servers         = ["1.1.1.1"]
  split_tunnel        = var.split_tunnel
  transport_protocol  = var.vpn_client_protocol
  session_timeout_hours = 8
  #self_service_portal = "enabled" # not possible at this time, due to current Google Workspaces SAML/SSO implementation

  security_group_ids = [aws_security_group.private_subnet_ssh.id, aws_security_group.icmp.id, aws_security_group.vpn_access.id]
  tags               = var.default_tags
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  #count = length(aws_subnet.private.id)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = aws_subnet.private.id

  lifecycle {
    // The issue why we are ignoring changes is that on every change
    // terraform screws up most of the vpn assosciations
    // see: https://github.com/hashicorp/terraform-provider-aws/issues/14717
    ignore_changes = [subnet_id]
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = aws_vpc.main.cidr_block
  authorize_all_groups   = var.authorize_all_groups
}

#resource "aws_ec2_client_vpn_route" "route" {
  #client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  #destination_cidr_block = "0.0.0.0/0"
  #target_vpc_subnet_id   = aws_ec2_client_vpn_network_association.vpn_subnets.subnet_id
#}
