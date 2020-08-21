resource "aws_efs_file_system" "ecs-efs" {
  count = "${var.dockerizedJenkins}"
  creation_token = "${var.envPrefix}-ecs-efs"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

// For Jenkins
resource "aws_efs_access_point" "jenkins-efs-ap" {
  count = "${var.dockerizedJenkins}"
  file_system_id = "${aws_efs_file_system.ecs-efs.id}"
  posix_user = {
    gid =  1000
    uid = 1000
  }
  root_directory = {
    path = "/data/jenkins"
    creation_info = {
      owner_gid = 1000
      owner_uid = 1000
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_mount_target" "jenkins-efs-mt" {
   count = "${var.dockerizedJenkins * 2}"
   file_system_id = "${aws_efs_file_system.ecs-efs.id}"
   subnet_id = "${element(aws_subnet.subnet_for_ecs_private.*.id, count.index)}"
   security_groups = ["${aws_security_group.vpc_sg.id}"]
}

// For ES
resource "aws_efs_file_system" "ecs-es-efs" {
  creation_token = "${var.envPrefix}-es-efs"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_access_point" "es-efs-ap" {
  file_system_id = "${aws_efs_file_system.ecs-es-efs.id}"
  posix_user = {
    gid =  0
    uid = 0
  }
  root_directory = {
    path = "/data/es"
    creation_info = {
      owner_gid = 0
      owner_uid = 0
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_mount_target" "es-efs-mt" {
   count = "2"
   file_system_id = "${aws_efs_file_system.ecs-es-efs.id}"
   subnet_id = "${element(aws_subnet.subnet_for_ecs_private.*.id, count.index)}"
   security_groups = ["${aws_security_group.vpc_sg_es_kibana.id}"]
}

//For CodeQuality

resource "aws_efs_file_system" "ecs-codeq-efs" {
  count = "${var.dockerizedSonarqube}"
  creation_token = "${var.envPrefix}-ecs-codeq-efs"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_access_point" "codeq-efs-ap-data" {
  count = "${var.dockerizedSonarqube}"
  file_system_id = "${aws_efs_file_system.ecs-codeq-efs.id}"
  posix_user = {
    gid =  0
    uid = 0
  }
  root_directory = {
    path = "/data/codeq"
    creation_info = {
      owner_gid = 0
      owner_uid = 0
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_access_point" "codeq-efs-ap-logs" {
  count = "${var.dockerizedSonarqube}"
  file_system_id = "${aws_efs_file_system.ecs-codeq-efs.id}"
  posix_user = {
    gid =  0
    uid = 0
  }
  root_directory = {
    path = "/logs/codeq"
    creation_info = {
      owner_gid = 0
      owner_uid = 0
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}
resource "aws_efs_access_point" "codeq-efs-ap-extension" {
  count = "${var.dockerizedSonarqube}"
  file_system_id = "${aws_efs_file_system.ecs-codeq-efs.id}"
  posix_user = {
    gid =  0
    uid = 0
  }
  root_directory = {
    path = "/extension/codeq"
    creation_info = {
      owner_gid = 0
      owner_uid = 0
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}
resource "aws_efs_access_point" "codeq-efs-ap-config" {
  count = "${var.dockerizedSonarqube}"
  file_system_id = "${aws_efs_file_system.ecs-codeq-efs.id}"
  posix_user = {
    gid =  0
    uid = 0
  }
  root_directory = {
    path = "/config/codeq"
    creation_info = {
      owner_gid = 0
      owner_uid = 0
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_mount_target" "codeq-efs-mt" {
   count = "${var.dockerizedSonarqube * 2}"
   file_system_id = "${aws_efs_file_system.ecs-codeq-efs.id}"
   subnet_id = "${element(aws_subnet.subnet_for_ecs_private.*.id, count.index)}"
   security_groups = ["${aws_security_group.vpc_sg.id}"]
}

//For Gitlab

resource "aws_efs_file_system" "ecs-gitlab-efs" {
  count = "${var.scmgitlab}"
  creation_token = "${var.envPrefix}-ecs-gitlab-efs"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_access_point" "gitlab-efs-ap-data" {
  count = "${var.scmgitlab}"
  file_system_id = "${aws_efs_file_system.ecs-gitlab-efs.id}"
  posix_user = {
    gid =  0
    uid = 0
  }
  root_directory = {
    path = "/data/gitlab"
    creation_info = {
      owner_gid = 0
      owner_uid = 0
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_access_point" "gitlab-efs-ap-logs" {
  count = "${var.scmgitlab}"
  file_system_id = "${aws_efs_file_system.ecs-gitlab-efs.id}"
  posix_user = {
    gid =  0
    uid = 0
  }
  root_directory = {
    path = "/logs/gitlab"
    creation_info = {
      owner_gid = 0
      owner_uid = 0
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_access_point" "gitlab-efs-ap-config" {
  count = "${var.scmgitlab}"
  file_system_id = "${aws_efs_file_system.ecs-gitlab-efs.id}"
  posix_user = {
    gid =  0
    uid = 0
  }
  root_directory = {
    path = "/config/gitlab"
    creation_info = {
      owner_gid = 0
      owner_uid = 0
      permissions = "0777"
    }
  }
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_efs_mount_target" "gitlab-efs-mt" {
   count = "${var.scmgitlab * 2}"
   file_system_id = "${aws_efs_file_system.ecs-gitlab-efs.id}"
   subnet_id = "${element(aws_subnet.subnet_for_ecs_private.*.id, count.index)}"
   security_groups = ["${aws_security_group.vpc_sg.id}"]
}