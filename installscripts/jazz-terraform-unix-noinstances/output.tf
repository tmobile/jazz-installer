#
# This resource will add necessary setting needed for the user into settings.txt
#
resource "null_resource" "outputVariables" {
  provisioner "local-exec" {
    command = "touch settings.txt"
  }
  provisioner "local-exec" {
    command = "echo bitbucketelb = http://${lookup(var.bitbucketservermap, "bitbucket_elb")} > settings.txt"
  }
  provisioner "local-exec" {
    command = "echo bitbucket publicip = ${lookup(var.bitbucketservermap, "bitbucket_public_ip")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkinselb = http://${lookup(var.jenkinsservermap, "jenkins_elb")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Jenkins Username = ${lookup(var.jenkinsservermap, "jenkinsuser")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Jenkins Password = ${lookup(var.jenkinsservermap, "jenkinspasswd")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkins-subnet = ${lookup(var.jenkinsservermap, "jenkins_subnet")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo cloudfront url = http://${aws_cloudfront_distribution.jazz.domain_name}/index.html >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Username = ${var.cognito_pool_username} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Password = ${var.cognito_pool_password} >> settings.txt"
  }
}
