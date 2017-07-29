resource "null_resource" "outputVariables" {
  depends_on = ["aws_elb_attachment.bitbucket","aws_elb_attachment.jenkins" ]
  provisioner "local-exec" {
    command = "echo bitbucketelb= ${aws_elb.bitbucketelb.dns_name} > settings.txt"
  }
  provisioner "local-exec" {
    command = "echo bitbucket publicip = ${aws_instance.bitbucketserver.public_ip} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkinselb= ${aws_elb.jenkinselb.dns_name} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkins-publicip = ${aws_instance.jenkinsserver.public_ip} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkins-subnet = ${var.subnet} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkins-securitygroup = ${aws_security_group.jenkins.id} >> settings.txt"
  }
}


