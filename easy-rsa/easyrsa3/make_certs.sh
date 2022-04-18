#!/bin/bash

# This script is based on the instructions located here:
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html

#uncomment if you need to troubleshoot
#set -x
# Initialize a new PKI environment.
./easyrsa init-pki

# To build a new certificate authority (CA), run this command and follow the prompts.
./easyrsa build-ca nopass

# Generate the server certificate and key.
./easyrsa build-server-full server nopass

# Generate the client certificate and key.
# Make sure to save the client certificate and the client private key because you will need them when you configure the client.
./easyrsa build-client-full client1.domain.tld nopass

# copy over required certificates (files) to terraform directory to
# upload to AWS ACM
CERT_DIR=../../terraform/certs

mkdir -pv $CERT_DIR
cp pki/ca.crt $CERT_DIR
cp pki/issued/server.crt $CERT_DIR
cp pki/private/server.key $CERT_DIR
cp pki/issued/client1.domain.tld.crt $CERT_DIR
cp pki/private/client1.domain.tld.key $CERT_DIR

exit 0
