#
# This resource will add necessary setting needed for the user into settings.txt
#
resource "null_resource" "outputVariables" {
  provisioner "local-exec" {
    command = "touch settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Jenkins ELB = http://${lookup(var.jenkinsservermap, "jenkins_elb")} > settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Jenkins Username = ${lookup(var.jenkinsservermap, "jenkinsuser")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Jenkins Password = ${lookup(var.jenkinsservermap, "jenkinspasswd")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Jenkins Subnet = ${lookup(var.jenkinsservermap, "jenkins_subnet")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Cloudfront URL = http://${aws_cloudfront_distribution.jazz.domain_name}/index.html >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Username = ${var.cognito_pool_username} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Password = ${var.cognito_pool_password} >> settings.txt"
  }
}

resource "null_resource" "outputVariablesBB" {
  depends_on = ["null_resource.outputVariables"]
  count = "${var.scmbb}"

  provisioner "local-exec" {
    command = "echo Bitbucket ELB = http://${lookup(var.scmmap, "elb")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Bitbucket publicip = ${lookup(var.scmmap, "publicip")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Bitbucket Username = ${lookup(var.scmmap, "username")}  >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Bitbucket Password = ${lookup(var.scmmap, "passwd")}  >> settings.txt"
  }
}

resource "null_resource" "outputVariablesGitlab" {
  depends_on = ["null_resource.outputVariables"]
  count = "${var.scmgitlab}"

  provisioner "local-exec" {
    command = "echo Gitlab PublicIP = http://${lookup(var.scmmap, "publicip")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Gitlab Username = ${lookup(var.scmmap, "username")}  >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Gitlab Password = ${lookup(var.scmmap, "passwd")}  >> settings.txt"
  }
}
