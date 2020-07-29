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

// Calling our db tier module
module "db_tier" {
  source = "./modules/db_tier"
  vpc_id = var.vpc_id
  name = var.name
  my_ip = var.my-ip
  internet_gateway_id = aws_internet_gateway.gw.id
}