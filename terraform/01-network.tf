resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name    = "${var.project} IGW"
    project = var.project
  }
}

//  Create a public subnet for each AZ.
resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr1
  availability_zone       = lookup(var.subnetaz1, var.aws_region)
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.igw]

  tags = {
    name    = "${var.project} Public Subnet A"
    project = var.project
  }
}

resource "aws_subnet" "public-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr2
  availability_zone       = lookup(var.subnetaz2, var.aws_region)
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.igw]

  tags = {
    name    = "${var.project} Public Subnet B"
    project = var.project
  }
}

resource "aws_subnet" "public-c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr3
  availability_zone       = lookup(var.subnetaz3, var.aws_region)
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.igw]

  tags = {
    name    = "${var.project} Public Subnet C"
    project = var.project
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    name    = "${var.project} Public Route Table"
    project = var.project
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-c" {
  subnet_id      = aws_subnet.public-c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "puppet-public-ssh" {
  name        = "public-ssh"
  description = "Security group that allows SSH traffic from internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name    = "${var.project} Public SSH"
    project = var.project
  }
}

resource "aws_security_group" "puppet-public-ssl" {
  name        = "${var.project}-public-ssl"
  description = "Security group that allows SSL traffic to internet"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name    = "${var.project} Public SSL Egress"
    project = var.project
  }
}

resource "aws_security_group" "puppet-public-puppet" {
  name        = "${var.project}-public-puppet"
  description = "Security group that allows puppet traffic internally"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = "8140"
    to_port     = "8140"
    protocol    = "6"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = "8140"
    to_port     = "8140"
    protocol    = "6"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    name    = "${var.project} puppet traffic"
    project = var.project
  }
}

resource "aws_vpc_dhcp_options" "mydhcp" {
    domain_name = var.dns_zone_name
    domain_name_servers = ["AmazonProvidedDNS"]
    tags = {
      Name = "My internal DHCP name"
    }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id = aws_vpc.vpc.id
    dhcp_options_id = aws_vpc_dhcp_options.mydhcp.id
}

resource "aws_route53_zone" "main" {
  name = var.dns_zone_name
  vpc {
    vpc_id = aws_vpc.vpc.id
  }
  comment = "Managed by x"
}

resource "aws_route53_record" "puppetmaster" {
   zone_id = aws_route53_zone.main.zone_id
   name = "puppetmaster.${var.dns_zone_name}"
   type = "A"
   ttl = "300"
   records = [
     aws_instance.puppetmaster.private_ip]
}

resource "aws_route53_record" "postgresdb" {
   zone_id = aws_route53_zone.main.zone_id
   name = "postgresdb.${var.dns_zone_name}"
   type = "A"
   ttl = "300"
   records = [
     aws_instance.postgresdb.private_ip]
}