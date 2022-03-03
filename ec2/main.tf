provider "aws" {
  #version = "~> 2.0"
  region  = "us-east-1"
}

# Criação da VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

# Criação de Subnet Pública A
resource "aws_subnet" "main_vpc_public_subnet_a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "main_vpc_public_subnet_a"
  }
}

# Criação de Subnet Pública B
resource "aws_subnet" "main_vpc_public_subnet_b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "main_vpc_public_subnet_b"
  }
}

# Criação de Subnet Privada A 
resource "aws_subnet" "main_vpc_private_subnet_a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "main_vpc_private_subnet_a"
  }
}

# Criação de Subnet Privada B 
resource "aws_subnet" "main_vpc_private_subnet_b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "main_vpc_private_subnet_a"
  }
}

# Criação do Internet Gateway
resource "aws_internet_gateway" "main_vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_vpc_igw"
  }
}

# Criação da Tabela de Roteamento
resource "aws_route_table" "main_vpc_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_vpc_igw.id
  }

  tags = {
    Name = "main_vpc_rt"
  }
}

# Criação da Rota Default para Acesso à Internet
resource "aws_route" "main_vpc_default_route" {
  route_table_id            = aws_route_table.main_vpc_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.main_vpc_igw.id
}

# Associação da Subnet Pública com a Tabela de Roteamento
resource "aws_route_table_association" "main_vpc_pub_association" {
  subnet_id      = aws_subnet.main_vpc_public_subnet_a.id
  route_table_id = aws_route_table.main_vpc_rt.id
}

resource "aws_security_group" "permitir_ssh_http" {
  name        = "permitir_ssh"
  description = "Permite SSH e HTTP na instancia EC2"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
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
    Name = "permitir_ssh_e_http"
  }
}

resource "aws_instance" "alura" {
  count = 3
  ami = "ami-0c293f3f676ec4f90"
  instance_type = "t2.micro"
  key_name = "terraform"
  subnet_id = aws_subnet.main_vpc_public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.permitir_ssh_http.id]
  associate_public_ip_address = true
  tags = {
    Name = "amzlinux${count.index}"
  }
}