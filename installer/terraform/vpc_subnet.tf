# For new VPC
resource "aws_vpc" "vpc_for_ecs" {
  count = "${var.autovpc}"
  cidr_block                       = "${var.vpc_cidr_block}"
  instance_tenancy                 = "default"
  enable_dns_hostnames             = "true"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

# VPC data resource for both new and existing vpc
data "aws_vpc" "vpc_data" {
  id = "${var.autovpc == 1 ? join(" ", aws_vpc.vpc_for_ecs.*.id) : var.existing_vpc_ecs }"
}

data "external" "instance_ip" {
  program = ["bash", "-c", "echo \"{\\\"ip\\\" : \\\"$(curl -s  checkip.amazonaws.com)\\\"}\""]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "instance_public_subnets" {
  vpc_id = "${data.aws_vpc.default.id}"
}

# VPC SG
resource "aws_security_group" "vpc_sg" {
    count = "${var.dockerizedJenkins}"
    name = "${var.envPrefix}_dockerized_sg"
    description = "ECS ALB access"
    vpc_id = "${data.aws_vpc.vpc_data.id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${concat(list("${aws_eip.elasticip.public_ip}/32"), list("${data.external.instance_ip.result.ip}/32"), split(",", var.network_range))}"]
    }
    ingress {
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        self = true
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_security_group" "vpc_sg_es_kibana" {
    name = "${var.envPrefix}_dockerized_es_sg"
    description = "ECS ALB access - ES"
    vpc_id = "${data.aws_vpc.vpc_data.id}"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${concat(list("${aws_eip.elasticip.public_ip}/32"), list("${data.external.instance_ip.result.ip}/32"), split(",", var.network_range))}"]
    }
    ingress {
        from_port = "${var.es_port_def}"
        to_port = "${var.es_port_def}"
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = "${var.es_port_def}"
        to_port = "${var.es_port_def}"
        protocol = "tcp"
        cidr_blocks = ["${concat(list("${aws_eip.elasticip.public_ip}/32"), list("${data.external.instance_ip.result.ip}/32"), split(",", var.network_range))}"]
    }
    ingress {
        from_port = "${var.es_port_tcp}"
        to_port = "${var.es_port_tcp}"
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = "${var.es_port_tcp}"
        to_port = "${var.es_port_tcp}"
        protocol = "tcp"
        cidr_blocks = ["${concat(list("${aws_eip.elasticip.public_ip}/32"), list("${data.external.instance_ip.result.ip}/32"), split(",", var.network_range))}"]
    }
    ingress {
        from_port = "${var.kibana_port_def}"
        to_port = "${var.kibana_port_def}"
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = "${var.kibana_port_def}"
        to_port = "${var.kibana_port_def}"
        protocol = "tcp"
        cidr_blocks = ["${concat(list("${aws_eip.elasticip.public_ip}/32"), list("${data.external.instance_ip.result.ip}/32"), split(",", var.network_range))}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_internet_gateway" "igw_for_ecs" {
  count = "${var.autovpc}"
  vpc_id = "${data.aws_vpc.vpc_data.id}"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

# Dynamic Subnet creation

resource "aws_subnet" "subnet_for_ecs" {
  count             = "${length(slice(data.aws_availability_zones.available.names, 0, 2))}"
  vpc_id            = "${data.aws_vpc.vpc_data.id}"
  availability_zone = "${element(slice(data.aws_availability_zones.available.names, 0, 2), count.index)}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.vpc_data.cidr_block, ceil(log(2 * 2, 2)), 2 + count.index)}"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

# For new VPC related resources
resource "aws_route_table" "route_table_for_ecs" {
  count = "${var.autovpc}"
  vpc_id = "${data.aws_vpc.vpc_data.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_for_ecs.id}"
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_main_route_table_association" "ecs_route_assoc" {
  count = "${var.autovpc}"
  vpc_id         = "${data.aws_vpc.vpc_data.id}"
  route_table_id = "${aws_route_table.route_table_for_ecs.id}"
}

resource "aws_network_acl" "public" {
  count      = "${var.autovpc}"
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
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_eip" "elasticip" {
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_nat_gateway" "natgtw" {
  allocation_id = "${aws_eip.elasticip.id}"
  subnet_id = "${element(split(",", join(",",aws_subnet.subnet_for_ecs.*.id)), 1)}"
}

resource "aws_subnet" "subnet_for_ecs_private" {
  count             = "${length(slice(data.aws_availability_zones.available.names, 0, 2))}"
  vpc_id            = "${data.aws_vpc.vpc_data.id}"
  availability_zone = "${element(slice(data.aws_availability_zones.available.names, 0, 2), count.index)}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.vpc_data.cidr_block, ceil(log(4 * 2, 2)), 2 + count.index)}"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_route_table" "privateroute" {
  vpc_id = "${data.aws_vpc.vpc_data.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgtw.id}"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}
resource "aws_route_table_association" "privateroute_assoc1" {
  route_table_id = "${aws_route_table.privateroute.id}"
  subnet_id      = "${element(aws_subnet.subnet_for_ecs_private.*.id, 1)}"
}
resource "aws_route_table_association" "privateroute_assoc2" {
  route_table_id = "${aws_route_table.privateroute.id}"
  subnet_id      = "${element(aws_subnet.subnet_for_ecs_private.*.id, 2)}"
}
