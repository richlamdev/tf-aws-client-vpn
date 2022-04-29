# Terraform AWS Client VPN Testing


aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id cvpn-endpoint-<YOUR-ENDPOINT-ID-HERE> --output text --profile cloud_user --region us-west-2 > downloaded-client-config.ovpn
