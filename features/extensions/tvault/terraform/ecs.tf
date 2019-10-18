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
    memory          = "${var.ecsTvaultmemory}"
    cpu             = "${var.ecsTvaultcpu}"
    admin_passwd    = "${var.jazzPassword}"
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
