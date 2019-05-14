resource "null_resource" "update_sonarqube_configs" {
  count = "${var.codeq}"

  #Configure sonarqube
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {SONAR_HOST_NAME} ${var.dockerizedSonarqube == 1 ? join(" ", aws_lb.alb_ecs_codeq.*.dns_name) : lookup(var.codeqmap, "sonar_server_elb") } ${var.jenkinsjsonpropsfile} BY_VALUE"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {ENABLE_SONAR} true ${var.jenkinsjsonpropsfile} BY_VALUE"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {ENABLE_VULNERABILITY_SCAN} true ${var.jenkinsjsonpropsfile} BY_VALUE"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {ENABLE_CODEQUALITY_TAB} true ${var.jenkinsjsonpropsfile} BY_VALUE"
  }
}
