# For new VPC
resource "aws_vpc" "vpc_for_ecs" {
  count = "${var.autovpc * var.dockerizedJenkins}"
  cidr_block                       = "${var.vpc_cidr_block}"
  instance_tenancy                 = "default"
  enable_dns_hostnames             = "true"
}

# VPC data resource for both new and existing vpc
data "aws_vpc" "vpc_data" {
  count = "${var.dockerizedJenkins}"
  id = "${var.existing_vpc_ecs}"
  id = "${var.autovpc == 1 ? join(" ", aws_vpc.vpc_for_ecs.*.id) : var.existing_vpc_ecs }"
}
# VPC SG
data "aws_security_group" "vpc_sg" {
  count = "${var.dockerizedJenkins}"
  vpc_id = "${data.aws_vpc.vpc_data.id}"
  name = "default"
}

resource "aws_internet_gateway" "igw_for_ecs" {
  count = "${var.autovpc * var.dockerizedJenkins}"
  vpc_id = "${data.aws_vpc.vpc_data.id}"
}

# Dynamic Subnet creation

resource "aws_subnet" "subnet_for_ecs" {
  count             = "${var.dockerizedJenkins * length(list("${var.region}a","${var.region}b"))}"
  vpc_id            = "${data.aws_vpc.vpc_data.id}"
  availability_zone = "${element(list("${var.region}a","${var.region}b"), count.index)}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.vpc_data.cidr_block, ceil(log(2 * 2, 2)), 2 + count.index)}"
}

# For new VPC related resources
resource "aws_route_table" "route_table_for_ecs" {
  count = "${var.autovpc * var.dockerizedJenkins}"
  vpc_id = "${data.aws_vpc.vpc_data.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_for_ecs.id}"
  }
}

resource "aws_main_route_table_association" "ecs_route_assoc" {
  count = "${var.autovpc * var.dockerizedJenkins}"
  vpc_id         = "${data.aws_vpc.vpc_data.id}"
  route_table_id = "${aws_route_table.route_table_for_ecs.id}"
}

resource "aws_network_acl" "public" {
  count      = "${var.autovpc * var.dockerizedJenkins}"
  vpc_id     = "${data.aws_vpc.vpc_data.id}"
  subnet_ids = ["${aws_subnet.subnet_for_ecs.*.id}"]

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }
}
