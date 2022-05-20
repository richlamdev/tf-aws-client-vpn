resource "null_resource" "get_openVPN_config" {
  provisioner "local-exec" {
    command = "aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn.id} --output text --profile cloud_user --region us-west-2 > ~/downloaded-client-config.ovpn"
  }
}

resource "local_file" "ssh_connection" {
  filename = "ssh_connect.sh"
  content  = <<EOF
ssh -i ~/.ssh/id_ed25519_tf_acg -o StrictHostKeyChecking=no ec2-user@${aws_instance.private_test[0].private_ip}
EOF
}
