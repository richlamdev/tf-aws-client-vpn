# This project deploys an AWS Client VPN with Terraform.  The following resources are created:

* AWS Certificate Manager (ACM) for the server certificate
***  * The server certificate can be created via Easy RSA, refer to the following:
   https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html

  * For mutual authentication be sure to generate client certificates.

  * For SAML/SSO only server certificates are required.  Google Workspace authentication
    implementation instructions are [here](https://benincosa.com/?p=3787)
    * SAML/SSO resource for the SAML/SSO Idp file

* AWS Client VPN w/ Authorization and Association

* CloudWatch log group and log stream

* Creates a Redhat EC2 instance to test be able to ping and/or SSH into.

* Security groups are set to allow inbound VPN connection to entire VPC, SSH, and ICMP.

## To use:

* 1) Create server certificate, server key file, and certificate chain.  Install to terraform/certs/ directory
     Obtain SAML/SSO IdP file if SAML/SSO authentication is the authentication method chosen.
* 2) Create client certificates, if mutual authentication is desired.  Uncomment section in vpn.tf to enable uploading of 
     client certificates.
* 3) Create appropriate SSH keypair and copy it to the appropriate directory to ensure it's pushed to the EC2 instance. (see code)
* 4) Run ```terraform init```, ```terraform plan```, ```terraform apply --auto-approve``` 
* 5) Download the OVPN file via the GUI. (or CLI)
* 6) Connect via OpenVPN client via SAML, ensure you logged into authorized Google account via your default OS browser.
* 7) Connect via OpenVPN client via client certificates, ensure client certificates are in the appropriate path.
