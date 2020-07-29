provider "aws" {
  region = "eu-west-1"
}

# Creating a vpc
resource "aws_vpc" "mainvpc" {
  cidr_block = "23.0.0.0/16"
  tags = {

    Name = "${var.name}tf.vpc"
  }
}

# Create an igw
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mainvpc.id
  tags = {
    Name = "${var.name} igw"
  }
}

// Calling our app tier module
module "app_tier" {
  source = "./modules/app_tier"
  name = var.name
  vpc_id = aws_vpc.mainvpc.id
  my_ip = var.my-ip
  internet_gateway_id = aws_internet_gateway.gw.id
  db_private_ip = aws_instance.DB.private_ip
}

// DB SETUP -- Private Subnet !

# Create private sub
resource "aws_subnet" "subprivate" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "23.0.2.0/24"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}sub.private"
  }
}

# Creating security group for db
resource "aws_security_group" "sgdb" {
  name        = "db-sg"
  description = "Allow http and https traffic"
  vpc_id      = aws_vpc.mainvpc.id

  ingress {
    description = "https from VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["23.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}sg.db"
  }
}

# Creating an ec2 instance IMAGE with our db
resource "aws_instance" "DB" {
  ami           = "ami-097a1923bb6d9c21d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subprivate.id
  vpc_security_group_ids = [aws_security_group.sgdb.id]
  tags = {
    Name = "${var.name}tf.db"
  }
}