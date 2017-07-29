provider "aws" {
	shared_credentials_file  = "C:/Users/admin/.aws/credentials"
	profile                  = "default"
    region = "us-east-1"
}
# Create a VPC to launch our instances into
resource "aws_vpc" "packer" {
  cidr_block = "10.0.0.0/16"
  provisioner "local-exec" {
    command = "echo set VPC_ID=${aws_vpc.packer.id} > ./setenv.cmd"
  }  
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "packer" {
  vpc_id = "${aws_vpc.packer.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.packer.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.packer.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "packer" {
  vpc_id                  = "${aws_vpc.packer.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  provisioner "local-exec" {
    command = "echo set SUBNET_ID=${aws_subnet.packer.id} >> ./setenv.cmd"
  }  
  provisioner "local-exec" {
    command = "echo set REGION=us-east-1>> ./setenv.cmd"
  }  
}