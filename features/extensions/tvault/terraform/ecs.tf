data "aws_iam_role" "ecs_role" {
  name = "${var.envPrefix}_ecs_execution_role"
}

resource "aws_ecs_cluster" "ecs_cluster_tvault" {
  name = "${var.envPrefix}_ecs_cluster_tvault"

  tags = "${local.common_tags}"
}

data "template_file" "ecs_task_tvault" {
  template = "${file("${path.module}/ecs_tvault_task_definition.json")}"

  vars {
    image           = "${var.tvault_docker_image}"
    ecs_container_name = "${var.envPrefix}_ecs_container_tvault"
    log_group       = "${var.envPrefix}_ecs_log"
    prefix_name     = "${var.envPrefix}_ecs_task_definition_tvault"
    region          = "${var.region}"
    admin_passwd    = "${var.jazzPassword}"
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition_tvault" {
  family                   = "${var.envPrefix}_ecs_task_definition_tvault"
  container_definitions    = "${data.template_file.ecs_task_tvault.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.ecsTvaultcpu}"
  memory                   = "${var.ecsTvaultmemory}"
  execution_role_arn       = "${data.aws_iam_role.ecs_role.arn}"
  task_role_arn            = "${data.aws_iam_role.ecs_role.arn}"

  tags = "${local.common_tags}"
}

resource "aws_alb_target_group" "alb_target_group_tvault" {
  name     = "${var.envPrefix}-ecs-tvault-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc_data.id}"
  target_type = "ip"

  health_check {
    path             = "/vault/swagger-ui.html"
    matcher          = "200"
    interval         = "60"
    timeout          = "59"
  }
  tags = "${local.common_tags}"
}

resource "aws_lb" "alb_ecs_tvault" {
  name            = "${var.envPrefix}-tvault-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.vpc_sg.id}"]
  subnets            = ["${data.aws_subnet_ids.private.ids}"]
  tags = "${local.common_tags}"
}

resource "aws_alb_listener" "ecs_alb_listener_tvault" {
  load_balancer_arn = "${aws_lb.alb_ecs_tvault.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group_tvault.arn}"
    type             = "forward"
  }
}

data "aws_ecs_task_definition" "ecs_task_definition_tvault" {
  task_definition = "${aws_ecs_task_definition.ecs_task_definition_tvault.family}"
}

resource "aws_ecs_service" "ecs_service_tvault" {
  name            = "${var.envPrefix}_ecs_service_tvault"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition_tvault.family}:${max("${aws_ecs_task_definition.ecs_task_definition_tvault.revision}", "${data.aws_ecs_task_definition.ecs_task_definition_tvault.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds  = 3000
  cluster =       "${aws_ecs_cluster.ecs_cluster_tvault.id}"

  network_configuration {
    security_groups    = ["${aws_security_group.vpc_sg.id}"]
    subnets            = ["${data.aws_subnet_ids.private.ids}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_tvault.arn}"
    container_name   = "${var.envPrefix}_ecs_container_tvault"
    container_port   = "80"
  }
  # Needed the below dependency since there is a bug in AWS provider
  depends_on = ["aws_alb_listener.ecs_alb_listener_tvault"]
}

resource "null_resource" "health_check_tvault" {
  depends_on = ["aws_ecs_service.ecs_service_tvault"]
  provisioner "local-exec" {
    command = "python ${var.healthCheck_cmd} ${aws_alb_target_group.alb_target_group_tvault.arn}"
  }
}
