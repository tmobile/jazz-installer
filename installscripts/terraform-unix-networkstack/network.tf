# Create a VPC to launch our instances into
resource "aws_vpc" "demo" {
  cidr_block = "${var.cidrblocks}"
  tags {  Name = "${var.envPrefix}_VPC"  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "demo" {
  vpc_id = "${aws_vpc.demo.id}"
  tags {  Name = "${var.envPrefix}_Gateway"  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.demo.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.demo.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "demo" {
  vpc_id                  = "${aws_vpc.demo.id}"
  cidr_block              = "${var.cidrblocks}"
  map_public_ip_on_launch = true
  tags {  Name = "${var.envPrefix}_subnet"  }
  
}
