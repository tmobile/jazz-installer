resource "null_resource" "outputVariables" {
//  depends_on = ["aws_elb_attachment.bitbucket","aws_elb_attachment.jenkins" ]
  provisioner "local-exec" {
    command = "echo bitbucketelb = http://${lookup(var.bitbucketservermap, "bitbucket_elb")}:7990 > settings.txt"
  }
  provisioner "local-exec" {
    command = "echo bitbucket publicip = ${lookup(var.bitbucketservermap, "bitbucket_public_ip")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkinselb = http://${lookup(var.jenkinsservermap, "jenkins_elb")}:8080 >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkins-publicip = ${lookup(var.jenkinsservermap, "jenkins_public_ip")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkins-subnet = ${lookup(var.jenkinsservermap, "subnet")} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo cloudfront url = http://${aws_cloudfront_distribution.jazz.domain_name}/index.html >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo Access Credentials:\n Username: ${var.cognito_pool_username}\n Password:  ${var.cognito_pool_password}" >> settings.txt"
  }
}
