data "aws_vpc" "vpc_data" {
  id = "${var.existing_vpc_ecs}"
}
resource "aws_security_group" "vpc_sg_tvault" {
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
    tags = "${local.common_tags}"
}
