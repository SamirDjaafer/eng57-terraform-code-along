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
  db_private_ip = module.db_tier.db_private_ip
}

// Calling our db tier module
module "db_tier" {
  source = "./modules/db_tier"
  vpc_id = aws_vpc.mainvpc.id
  name = var.name
  my_ip = var.my-ip
  internet_gateway_id = aws_internet_gateway.gw.id
  sg-app = module.app_tier.security_group_id
  subpublic_cidr_block = module.app_tier.subpublic_cidr_block
}