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

resource "aws_ecs_cluster" "ecs_cluster_jenkins" {
  count = "${var.dockerizedJenkins}"
  name = "${var.envPrefix}_ecs_cluster_jenkins"

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_ecs_cluster" "ecs_cluster_gitlab" {
  count = "${var.scmgitlab}"
  name = "${var.envPrefix}_ecs_cluster_gitlab"

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_ecs_cluster" "ecs_cluster_codeq" {
  count = "${var.dockerizedSonarqube}"
  name = "${var.envPrefix}_ecs_cluster_codeq"

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

data "template_file" "ecs_task_jenkins" {
  count = "${var.dockerizedJenkins}"
  template = "${file("${path.module}/ecs_jenkins_task_definition.json")}"

  vars {
    image           = "${var.jenkins_docker_image}"
    ecs_container_name = "${var.envPrefix}_ecs_container_jenkins"
    log_group       = "${aws_cloudwatch_log_group.ecs_fargates_cwlogs.name}"
    prefix_name     = "${var.envPrefix}_ecs_task_definition_jenkins"
    region          = "${var.region}"
    memory          = "${var.ecsJenkinsmemory}"
    cpu             = "${var.ecsJenkinscpu}"
    jenkins_user    = "${lookup(var.jenkinsservermap, "jenkinsuser")}"
    jenkins_passwd    = "${lookup(var.jenkinsservermap, "jenkinspasswd")}"
  }
}

data "template_file" "ecs_task_gitlab" {
  count = "${var.dockerizedJenkins}"
  template = "${file("${path.module}/ecs_gitlab_task_definition.json")}"

  vars {
    image           = "${var.gitlab_docker_image}"
    ecs_container_name = "${var.envPrefix}_ecs_container_gitlab"
    log_group       = "${aws_cloudwatch_log_group.ecs_fargates_cwlogs.name}"
    prefix_name     = "${var.envPrefix}_ecs_task_definition_gitlab"
    region          = "${var.region}"
    memory          = "${var.ecsGitlabmemory}"
    cpu             = "${var.ecsGitlabcpu}"
    gitlab_passwd    = "${var.cognito_pool_password}"
    external_url     = "http://${aws_lb.alb_ecs_gitlab.dns_name}"
  }
}

data "template_file" "ecs_task_codeq" {
  count = "${var.dockerizedJenkins}"
  template = "${file("${path.module}/ecs_codeq_task_definition.json")}"

  vars {
    image           = "${var.codeq_docker_image}"
    ecs_container_name = "${var.envPrefix}_ecs_container_codeq"
    log_group       = "${aws_cloudwatch_log_group.ecs_fargates_cwlogs.name}"
    prefix_name     = "${var.envPrefix}_ecs_task_definition_codeq"
    region          = "${var.region}"
    memory          = "${var.ecsSonarqubememory}"
    cpu             = "${var.ecsSonarqubecpu}"
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition_jenkins" {
  count = "${var.dockerizedJenkins}"
  family                   = "${var.envPrefix}_ecs_task_definition_jenkins"
  container_definitions    = "${data.template_file.ecs_task_jenkins.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.ecsJenkinscpu}"
  memory                   = "${var.ecsJenkinsmemory}"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_ecs_task_definition" "ecs_task_definition_gitlab" {
  count = "${var.scmgitlab}"
  family                   = "${var.envPrefix}_ecs_task_definition_gitlab"
  container_definitions    = "${data.template_file.ecs_task_gitlab.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.ecsGitlabcpu}"
  memory                   = "${var.ecsGitlabmemory}"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_ecs_task_definition" "ecs_task_definition_codeq" {
  count = "${var.dockerizedSonarqube}"
  family                   = "${var.envPrefix}_ecs_task_definition_codeq"
  container_definitions    = "${data.template_file.ecs_task_codeq.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      =  "${var.ecsSonarqubecpu}"
  memory                   =  "${var.ecsSonarqubememory}"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_alb_target_group" "alb_target_group_jenkins" {
  count = "${var.dockerizedJenkins}"
  name     = "${var.envPrefix}-ecs-jenkins-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc_data.id}"
  target_type = "ip"

  health_check {
    path             = "/login"
    matcher          = "200"
    interval         = "60"
    timeout          = "59"
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_alb_target_group" "alb_target_group_gitlab" {
 count = "${var.dockerizedJenkins * var.scmgitlab}"
  name     = "${var.envPrefix}-ecs-gitlab-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc_data.id}"
  target_type = "ip"

  health_check {
    path             = "/users/sign_in"
    matcher          = "200"
    interval         = "60"
    timeout          = "59"
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_alb_target_group" "alb_target_group_codeq" {
  count = "${var.dockerizedSonarqube}"
  name     = "${var.envPrefix}-ecs-codeq-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc_data.id}"
  target_type = "ip"

  health_check {
    path             = "/api/webservices/list"
    matcher          = "200"
    interval         = "60"
    timeout          = "59"
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_lb" "alb_ecs_jenkins" {
  count = "${var.dockerizedJenkins}"
  name            = "${var.envPrefix}-jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.vpc_sg.id}"]
  subnets            = ["${aws_subnet.subnet_for_ecs.*.id}"]
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_lb" "alb_ecs_gitlab" {
  count = "${var.dockerizedJenkins * var.scmgitlab}"
  name            = "${var.envPrefix}-gitlab-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.vpc_sg.id}"]
  subnets            = ["${aws_subnet.subnet_for_ecs.*.id}"]
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_lb" "alb_ecs_codeq" {
  count = "${var.dockerizedSonarqube}"
  name            = "${var.envPrefix}-codeq-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.vpc_sg.id}"]
  subnets            = ["${aws_subnet.subnet_for_ecs.*.id}"]
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_alb_listener" "ecs_alb_listener_jenkins" {
  count = "${var.dockerizedJenkins}"
  load_balancer_arn = "${aws_lb.alb_ecs_jenkins.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group_jenkins.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "ecs_alb_listener_gitlab" {
  count = "${var.scmgitlab}"
  load_balancer_arn = "${aws_lb.alb_ecs_gitlab.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group_gitlab.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "ecs_alb_listener_codeq" {
  count = "${var.dockerizedSonarqube}"
  load_balancer_arn = "${aws_lb.alb_ecs_codeq.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group_codeq.arn}"
    type             = "forward"
  }
}

data "aws_ecs_task_definition" "ecs_task_definition_jenkins" {
  count = "${var.dockerizedJenkins}"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition_jenkins.family}"
}

data "aws_ecs_task_definition" "ecs_task_definition_gitlab" {
  count = "${var.scmgitlab}"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition_gitlab.family}"
}

data "aws_ecs_task_definition" "ecs_task_definition_codeq" {
  count = "${var.dockerizedSonarqube}"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition_codeq.family}"
}

resource "aws_ecs_service" "ecs_service_jenkins" {
  count = "${var.dockerizedJenkins}"
  name            = "${var.envPrefix}_ecs_service_jenkins"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition_jenkins.family}:${max("${aws_ecs_task_definition.ecs_task_definition_jenkins.revision}", "${data.aws_ecs_task_definition.ecs_task_definition_jenkins.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds  = 3000
  cluster =       "${aws_ecs_cluster.ecs_cluster_jenkins.id}"

  network_configuration {
    security_groups    = ["${aws_security_group.vpc_sg.id}"]
    subnets            = ["${aws_subnet.subnet_for_ecs.*.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_jenkins.arn}"
    container_name   = "${var.envPrefix}_ecs_container_jenkins"
    container_port   = "8080"
  }
  # Needed the below dependency since there is a bug in AWS provider
  depends_on = ["aws_alb_listener.ecs_alb_listener_jenkins"]
}

resource "aws_ecs_service" "ecs_service_gitlab" {
  count = "${var.scmgitlab}"
  name            = "${var.envPrefix}_ecs_service_gitlab"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition_gitlab.family}:${max("${aws_ecs_task_definition.ecs_task_definition_gitlab.revision}", "${data.aws_ecs_task_definition.ecs_task_definition_gitlab.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds  = 3000
  cluster =       "${aws_ecs_cluster.ecs_cluster_gitlab.id}"

  network_configuration {
    security_groups    = ["${aws_security_group.vpc_sg.id}"]
    subnets            = ["${aws_subnet.subnet_for_ecs.*.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_gitlab.arn}"
    container_name   = "${var.envPrefix}_ecs_container_gitlab"
    container_port   = "80"
  }
  # Needed the below dependency since there is a bug in AWS provider
  depends_on = ["aws_alb_listener.ecs_alb_listener_gitlab"]
}

resource "aws_ecs_service" "ecs_service_codeq" {
  count = "${var.dockerizedSonarqube}"
  name            = "${var.envPrefix}_ecs_service_codeq"
  task_definition = "${aws_ecs_task_definition.ecs_task_definition_codeq.family}:${max("${aws_ecs_task_definition.ecs_task_definition_codeq.revision}", "${data.aws_ecs_task_definition.ecs_task_definition_codeq.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds  = 3000
  cluster =       "${aws_ecs_cluster.ecs_cluster_codeq.id}"

  network_configuration {
    security_groups    = ["${aws_security_group.vpc_sg.id}"]
    subnets            = ["${aws_subnet.subnet_for_ecs.*.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_codeq.arn}"
    container_name   = "${var.envPrefix}_ecs_container_codeq"
    container_port   = "9000"
  }
  # Needed the below dependency since there is a bug in AWS provider
  depends_on = ["aws_alb_listener.ecs_alb_listener_codeq"]
}

resource "null_resource" "health_check_jenkins" {
  count = "${var.dockerizedJenkins}"
  depends_on = ["aws_ecs_service.ecs_service_jenkins"]
  provisioner "local-exec" {
    command = "python ${var.healthCheck_cmd} ${aws_alb_target_group.alb_target_group_jenkins.arn}"
  }
}

resource "null_resource" "health_check_gitlab" {
  count = "${var.scmgitlab}"
  depends_on = ["aws_ecs_service.ecs_service_gitlab"]
  provisioner "local-exec" {
    command = "python ${var.healthCheck_cmd} ${aws_alb_target_group.alb_target_group_gitlab.arn}"
  }
}

resource "null_resource" "health_check_codeq" {
  count = "${var.dockerizedSonarqube}"
  depends_on = ["aws_ecs_service.ecs_service_codeq"]
  provisioner "local-exec" {
    command = "python ${var.healthCheck_cmd} ${aws_alb_target_group.alb_target_group_codeq.arn}"
  }
}
