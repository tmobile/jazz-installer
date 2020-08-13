resource "aws_efs_file_system" "jenkins-efs" {
  count = "${var.dockerizedJenkins}"
  creation_token = "${var.envPrefix}-jenkins-efs"
  encrypted = true
  tags = {
    Name = "${var.envPrefix}-jenkins-efs-fs"
  }
}

resource "aws_efs_access_point" "jenkins-efs-ap" {
  count = "${var.dockerizedJenkins}"
  file_system_id = "${aws_efs_file_system.jenkins-efs.id}"
  posix_user = {
    gid =  1000
    uid = 1000
  }
  root_directory = {
    path = "/data/jenkins"
  }
  tags = {
    Name = "${var.envPrefix}-jenkins-efs-ap"
  }
}

resource "aws_efs_mount_target" "jenkins-efs-mt" {
   count = "2"
   file_system_id = "${aws_efs_file_system.jenkins-efs.id}"
   subnet_id = "${element(aws_subnet.subnet_for_ecs_private.*.id, count.index)}"
   security_groups = ["${aws_security_group.vpc_sg.id}"]
}