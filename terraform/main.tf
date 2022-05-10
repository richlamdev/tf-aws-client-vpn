########################### NEW VPC ##############################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = var.default_tags
}
########################### NEW VPC ##############################

########################### SUBNETS ##############################

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  # 251 IP addresses each
  cidr_block        = var.private_subnet
  availability_zone = "us-west-2a"
  tags = merge(var.default_tags, {
    Name = "10.0.1.0 - Public Subnet"
    },
  )
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  # 251 IP addresses each
  cidr_block        = var.public_subnet
  availability_zone = "us-west-2a"
  tags = merge(var.default_tags, {
    Name = "10.0.2.0 - Private Subnet"
    },
  )
}
########################### SUBNETS ##############################

########################### INTERNET GATWAY ######################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.default_tags, {
    Name      = "igw"
    CreatedBy = "tf-syslog-ng"
    },
  )
}

# create route table and attach to Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.default_tags, {
    Name = "public_route_table"
    },
  )
}

# associate designated subnet to public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
########################### INTERNET GATWAY ######################

########################### NAT GATWAY ###########################
resource "aws_eip" "ngw" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public.id

  # ensure proper ordering; add an explicit dependency on the IGW for the VPC
  depends_on = [aws_internet_gateway.igw]
  tags       = var.default_tags
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = merge(var.default_tags, {
    Name = "private_route_table"
    },
  )
}

# associate private subnet with private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
########################### NAT GATWAY ###########################

############################ EC2 INSTANCES ########################
resource "aws_key_pair" "ssh" {
  key_name   = "ssh_key_pair"
  public_key = file(pathexpand("~/.ssh/id_ed25519_tf_acg.pub"))
  tags = merge(var.default_tags, {
    Name = "ssh_key_pair"
    },
  )
}

data "aws_ami" "latest-Redhat" {
  most_recent = true
  owners      = ["309956199498"] # Redhat owner ID

  filter {
    name   = "name"
    values = ["RHEL_HA-8.5.0_HVM-2*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  tags = var.default_tags
}

# public instance
#resource "aws_instance" "public_test" {
#count           = 5
#ami             = data.aws_ami.latest-Redhat.id # Get latest RH 8.5x image
#subnet_id       = aws_subnet.public.id
#security_groups = [aws_security_group.public_ssh.id, aws_security_group.icmp.id, aws_security_group.syslog_ng.id, aws_security_group.dns.id]
#instance_type   = "t3.micro"
##iam_instance_profile = "EC2SSMRole"
#key_name = "ssh_key_pair"
#tags = merge(var.default_tags, {
#Name = "public-instance-test"
#},
#)
#}

resource "aws_instance" "private_test" {
  ami             = data.aws_ami.latest-Redhat.id # Get latest RH 8.5x image
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.private_subnet_ssh.id, aws_security_group.icmp.id]
  instance_type   = "t3.micro"
  count           = 1
  key_name        = "ssh_key_pair"

  tags = merge(var.default_tags, {
    Name = "private-instance-test"
    },
  )

}
########################### EC2 INSTANCES ########################
