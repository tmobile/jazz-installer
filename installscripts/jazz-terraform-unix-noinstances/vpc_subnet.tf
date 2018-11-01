resource "aws_vpc" "vpc_for_ecs" {
  count = "${var.autovpc * var.dockerizedJenkins}"
  cidr_block                       = "${var.vpc_cidr_block}"
  instance_tenancy                 = "default"
  enable_dns_hostnames             = "true"
}

resource "aws_internet_gateway" "igw_for_ecs" {
  count = "${var.autovpc * var.dockerizedJenkins}"
  vpc_id = "${aws_vpc.vpc_for_ecs.id}"
}

resource "aws_subnet" "subnet_for_ecs" {
  count             = "${var.autovpc * var.dockerizedJenkins * length(list("${var.region}a","${var.region}b"))}"
  vpc_id            = "${aws_vpc.vpc_for_ecs.id}"
  availability_zone = "${element(list("${var.region}a","${var.region}b"), count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc_for_ecs.cidr_block, ceil(log(2 * 2, 2)), 2 + count.index)}"

}
resource "aws_route_table" "route_table_for_ecs" {
  count = "${var.autovpc * var.dockerizedJenkins}"
  vpc_id = "${aws_vpc.vpc_for_ecs.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_for_ecs.id}"
  }
}

resource "aws_main_route_table_association" "ecs_route_assoc" {
  count = "${var.autovpc * var.dockerizedJenkins}"
  vpc_id         = "${aws_vpc.vpc_for_ecs.id}"
  route_table_id = "${aws_route_table.route_table_for_ecs.id}"
}

resource "aws_network_acl" "public" {
  count      = "${var.autovpc * var.dockerizedJenkins}"
  vpc_id     = "${aws_vpc.vpc_for_ecs.id}"
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
