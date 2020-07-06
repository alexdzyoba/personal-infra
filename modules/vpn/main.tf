resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "172.16.254.0/23"

  tags = {
    Name = var.name
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

resource "aws_security_group" "ssh_ipsec" {
  name        = "allow_ssh_ipsec"
  description = "Allow SSH and IPsec inbound traffic"

  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "IKE"
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "IPsec NAT traversal"
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wireguard"
    from_port   = var.wireguard_port
    to_port     = var.wireguard_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}

data "aws_ami" "ubuntu" {
  owners = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20200701"]
  }
}

resource "aws_instance" "vpn" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = var.ssh_key_pair_name

  subnet_id = aws_subnet.subnet.id
  vpc_security_group_ids = [
    aws_security_group.ssh_ipsec.id,
  ]
  associate_public_ip_address = true

  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    delete_on_termination = true
    volume_size           = var.instance_disk_size
    encrypted             = true
  }

  tags = {
    Name = var.name
    Role = "vpn"
  }
}

resource "aws_eip" "public" {
  instance = aws_instance.vpn.id
  vpc      = true
}
