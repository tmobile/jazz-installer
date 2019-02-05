
output "jenkinselb" {
  value = "http://${var.dockerizedJenkins == 1 ? join(" ", aws_lb.alb_ecs_jenkins.*.dns_name) : lookup(var.jenkinsservermap, "jenkins_elb") }"
}
output "jenkinsuser" {
  value = "${lookup(var.jenkinsservermap, "jenkinsuser")}"
}
output "jenkinspasswd" {
  value = "${lookup(var.jenkinsservermap, "jenkinspasswd")}"
}
output "jazzhome" {
  value = "http://${aws_cloudfront_distribution.jazz.domain_name}"
}
output "jazzusername" {
  value = "${var.cognito_pool_username}"
}
output "jazzpassword" {
  value = "${var.cognito_pool_password}"
}
output "region" {
  value = "${var.region}"
}
output "apiendpoint" {
  value = "https://${aws_api_gateway_rest_api.jazz-prod.id}.execute-api.${var.region}.amazonaws.com/prod"
}
output "scmbb" {
  value = "${var.scmbb}"
}
output "codeq" {
  value = "${var.codeq}"
}
output "scmgitlab" {
  value = "${var.scmgitlab}"
}
output "sonarhome" {
  value = "http://${var.dockerizedSonarqube == 1 ? join(" ", aws_lb.alb_ecs_codeq.*.dns_name) : lookup(var.codeqmap, "sonar_server_elb") }"
}
output "sonarusername" {
  value = "${lookup(var.codeqmap, "sonar_username")}"
}
output "sonarpasswd" {
  value = "${lookup(var.codeqmap, "sonar_passwd")}"
}
output "scmelb" {
  value = "http://${var.scmgitlab == 1 ? join(" ", aws_lb.alb_ecs_gitlab.*.dns_name) : lookup(var.scmmap, "scm_elb")}"
}
output "scmusername" {
  value = "${lookup(var.scmmap, "scm_username")}"
}
output "scmpasswd" {
  value = "${lookup(var.scmmap, "scm_passwd")}"
}
