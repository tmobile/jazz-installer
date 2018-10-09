resource "aws_iam_role_policy" "ecs_execution_policy" {
  count = "${var.dockerizedJenkins}"
  name = "${var.envPrefix}_ecs_execution_policy"
  role = "${aws_iam_role.ecs_execution_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_execution_role" {
  count = "${var.dockerizedJenkins}"
  name = "${var.envPrefix}_ecs_execution_role"

 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "ecs_fargates_cwlogs" {
  count = "${var.dockerizedJenkins}"
  name = "${var.envPrefix}_ecs_log"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "ecs_cluster" {
  count = "${var.dockerizedJenkins}"
  name = "${var.envPrefix}_ecs_cluster"
}

data "template_file" "ecs_task" {
  template = "${file("${path.module}/ecs_jenkins_task_definition.json")}"

  vars {
    image           = "${var.jenkins_docker_image}"
    ecs_container_name = "${var.envPrefix}_ecs_container"
    log_group       = "${aws_cloudwatch_log_group.ecs_fargates_cwlogs.name}"
    prefix_name     = "${var.envPrefix}_ecs_task_definition"
    region          = "${var.region}"
    jenkins_user    = "${lookup(var.jenkinsservermap, "jenkinsuser")}"
    jenkins_passwd    = "${lookup(var.jenkinsservermap, "jenkinspasswd")}"
  }
  depends_on = ["aws_cloudwatch_log_group.ecs_fargates_cwlogs"]
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  count = "${var.dockerizedJenkins}"
  family                   = "${var.envPrefix}_ecs_task_definition"
  container_definitions    = "${data.template_file.ecs_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

resource "aws_alb_target_group" "alb_target_group" {
  count = "${var.dockerizedJenkins}"
  name     = "${var.envPrefix}-ecs-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${lookup(var.jenkinsservermap, "jenkins_vpc_id")}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path             = "/login"
    matcher          = "200"
    interval         = "60"
    timeout          = "59"
  }
}

resource "aws_lb" "alb_ecs" {
  count = "${var.dockerizedJenkins}"
  name            = "${var.envPrefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${lookup(var.jenkinsservermap, "jenkins_security_group")}"]
  subnets            = ["${lookup(var.jenkinsservermap, "jenkins_subnet")}", "${lookup(var.jenkinsservermap, "jenkins_subnet2")}"]

  tags {
    Name        = "${var.envPrefix}_alb"
  }
}

resource "aws_alb_listener" "ecs_alb_listener" {
  count = "${var.dockerizedJenkins}"
  load_balancer_arn = "${aws_lb.alb_ecs.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}

data "aws_ecs_task_definition" "ecs_task_definition" {
  count = "${var.dockerizedJenkins}"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition.family}"
}

resource "aws_ecs_service" "ecs_service" {
  count = "${var.dockerizedJenkins}"
  name            = "${var.envPrefix}_ecs_service"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition.family}:${max("${aws_ecs_task_definition.ecs_task_definition.revision}", "${data.aws_ecs_task_definition.ecs_task_definition.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds  = 3000
  cluster =       "${aws_ecs_cluster.ecs_cluster.id}"

  network_configuration {
    security_groups    = ["${lookup(var.jenkinsservermap, "jenkins_security_group")}"]
    subnets            = ["${lookup(var.jenkinsservermap, "jenkins_subnet")}", "${lookup(var.jenkinsservermap, "jenkins_subnet2")}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    container_name   = "${var.envPrefix}_ecs_container"
    container_port   = "8080"
  }
  depends_on = ["aws_alb_target_group.alb_target_group", "aws_lb.alb_ecs"]
}
