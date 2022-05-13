resource "aws_cloudwatch_log_group" "client_vpn" {
  name = "aws_client_vpn"

  tags = var.default_tags
}

resource "aws_cloudwatch_log_stream" "logs" {
  name           = "connection_logs"
  log_group_name = "${aws_cloudwatch_log_group.client_vpn.name}"
}

resource "aws_iam_saml_provider" "default" {
  name                   = "Google_IdP"
  saml_metadata_document = file("idp_meta_data/GoogleIDPMetadata.xml")
  tags                   = var.default_tags
}
