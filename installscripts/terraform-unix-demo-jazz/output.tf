resource "null_resource" "outputVariables" {
  depends_on = ["aws_elb_attachment.bitbucket","aws_elb_attachment.jenkins" ]
  provisioner "local-exec" {
    command = "echo bitbucketelb = http://${aws_elb.bitbucketelb.dns_name}:7990 > settings.txt"
  }
  provisioner "local-exec" {
    command = "echo bitbucket publicip = ${aws_instance.bitbucketserver.public_ip} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkinselb = http://${aws_elb.jenkinselb.dns_name}:8080 >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkins-publicip = ${aws_instance.jenkinsserver.public_ip} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo jenkins-subnet = ${var.subnet} >> settings.txt"
  }
  provisioner "local-exec" {
    command = "echo cloudfront url = http://${aws_cloudfront_distribution.jazz.domain_name}/index.html >> settings.txt"
  }
}


