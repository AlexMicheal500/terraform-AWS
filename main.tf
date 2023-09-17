# This was gotten from Provider in https://registry.terraform.io/providers/hashicorp/aws/latest/docs

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAWIUQRA52KKXWNSUI"
  secret_key = "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"
}

# 1. Create an EC2 instance
# 2. Craete a VPC
# 3. Create Internet Gateway
# 4. Create Route-table
# 5. Create Subnet

# Creation of an EC2 Server https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "my-first-server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my-first-subnet.id

  tags = {
    Name = "Ubuntu"
  }
}

# Creation of VPC https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc.html
resource "aws_vpc" "test-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "My-VPC"
  }
}

# Creation of Internet Gateway https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.test-VPC.id

  tags = {
    Name = "Sample-Internet-Gateway"
  }
}

# Creation of a subnet https://registry.terraform.io/providers/hashicorp/aws/3.9.0/docs/resources/subnet
resource "aws_subnet" "my-first-subnet" {
  vpc_id     = aws_vpc.test-VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "My-SUBNET"
  }
}

# Creation od security group
resource "aws_security_group" "allow_web" {
  name        = "Security_group_1"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.test-VPC.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_security_group"
  }
}

# Create a Route-table using https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.test-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "routetable"
  }
}

# Creation of a Network Interface https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface
resource "aws_network_interface" "test-network-interface" {
  subnet_id       = aws_subnet.my-first-subnet.id
  private_ips     = ["10.0.1.57"]
  security_groups = [aws_security_group.allow_web.id]

  attachment {
    instance     = aws_instance.my-first-server.id
    device_index = 1
  }
}
