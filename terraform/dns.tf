########################### DHCP OPTIONS #########################
resource "aws_vpc_dhcp_options" "config" {
  domain_name = "tatooine.test"
  #domain_name_servers = ["127.0.0.1", "10.0.0.2"]
  #domain_name_servers = ["AmazonProvidedDNS", "${aws_instance.public_test[2].private_ip}" ]
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = merge(var.default_tags, {
    Name = "VPC DCHP Options"
    },
  )
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.config.id
}

resource "aws_route53_zone" "private" {
  name = "tatooine.test"

  vpc {
    vpc_id = aws_vpc.main.id
  }
  tags = merge(var.default_tags, {
    Name = "aws_vpc_dhcp_options_association"
    },
  )
}

resource "aws_route53_record" "domain_records" {
  zone_id         = aws_route53_zone.private.zone_id
  allow_overwrite = true
  name            = "richy"
  type            = "A"
  ttl             = "300"
  records         = "192.168.100.100"
}
