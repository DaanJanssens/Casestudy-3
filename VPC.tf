resource "aws_vpc" "innovatech" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "lb_subnet_01" {
  vpc_id            = aws_vpc.innovatech.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = var.zone1
  tags = {
    Name = "lb_subnet_01"
  }
}

resource "aws_subnet" "lb_subnet_02" {
  vpc_id            = aws_vpc.innovatech.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = var.zone2
  tags = {
    Name = "lb_subent_02"
  }
}

resource "aws_subnet" "web_subnet_01" {
  vpc_id            = aws_vpc.innovatech.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = var.zone1
  tags = {
    Name = "web_subnet_01"
  }
}

resource "aws_subnet" "web_subnet_02" {
  vpc_id = aws_vpc.innovatech.id
  cidr_block = "192.168.6.0/24"
  availability_zone = var.zone2
  tags = {
    Name = "web_subnet_02"
  }
}

resource "aws_subnet" "db_subnet_01" {
  vpc_id            = aws_vpc.innovatech.id
  cidr_block        = "192.168.4.0/24"
  availability_zone = var.zone1
  tags = {
    Name = "db_subnet_01"
  }
}

resource "aws_subnet" "db_subnet_02" {
  vpc_id            = aws_vpc.innovatech.id
  cidr_block        = "192.168.5.0/24"
  availability_zone = var.zone2
  tags = {
    Name = "db_subnet_02"
  }
}