resource "aws_rds_cluster" "casbin" {
  cluster_identifier      = "casbin-cluster"
  availability_zones      = ["us-east-1a", "us-east-1b"]
  database_name           = "${var.acl_db_name}"
  master_username         = "${var.acl_db_username}"
  master_password         = "${var.acl_db_password}"
  port                    = "${var.acl_db_port}"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot = true
  engine                  = "aurora-mysql"
  engine_version          = "5.7.12"
  vpc_security_group_ids  = ["${aws_security_group.acl_sg.id}"]

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_rds_cluster_instance" "casbin-instance" {
  apply_immediately       = true
  cluster_identifier      = "${aws_rds_cluster.casbin.id}"
  identifier              = "casbin"
  instance_class          = "db.t2.small"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.12"
  publicly_accessible     = true

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

#TODO: CIDR block will be refined/more restricted in the next version
resource "aws_security_group" "acl_sg" {
    name = "acl_sg"
    description = "Aurora MySQL access"
    ingress {
        from_port = "${var.acl_db_port}"
        to_port = "${var.acl_db_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = "${merge(var.additional_tags, local.common_tags)}"
}
