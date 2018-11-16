
output "op-jenkinselb" {
  value = "http://${var.dockerizedJenkins == 1 ? join(" ", aws_lb.alb_ecs.*.dns_name) : lookup(var.jenkinsservermap, "jenkins_elb") }"
}
output "op-jenkinsuser" {
  value = "${lookup(var.jenkinsservermap, "jenkinsuser")}"
}
output "op-jenkinspasswd" {
  value = "${lookup(var.jenkinsservermap, "jenkinspasswd")}"
}
output "op-jazzhome" {
  value = "http://${aws_cloudfront_distribution.jazz.domain_name}"
}
output "op-jazzusername" {
  value = "${var.cognito_pool_username}"
}
output "op-jazzpassword" {
  value = "${var.cognito_pool_password}"
}
output "op-region" {
  value = "${var.region}"
}
output "op-apiendpoint" {
  value = "https://${aws_api_gateway_rest_api.jazz-prod.id}.execute-api.${var.region}.amazonaws.com/prod"
}
output "op-scmbb" {
  value = "${var.scmbb}"
}
output "op-codeq" {
  value = "${var.codeq}"
}
output "op-scmgitlab" {
  value = "${var.scmgitlab}"
}
output "op-sonarhome" {
  value = "http://${var.dockerizedSonarqube == 1 ? join(" ", aws_lb.alb_ecs_codeq.*.dns_name) : lookup(var.codeqmap, "sonar_server_elb") }"
}
output "op-sonarusername" {
  value = "${lookup(var.codeqmap, "sonar_username")}"
}
output "op-sonarpasswd" {
  value = "${lookup(var.codeqmap, "sonar_passwd")}"
}
output "op-scmelb" {
  value = "http://${var.scmgitlab == 1 ? join(" ", aws_lb.alb_ecs_gitlab.*.dns_name) : lookup(var.scmmap, "scm_elb")}"
}
output "op-scmusername" {
  value = "${lookup(var.scmmap, "scm_username")}"
}
output "op-scmpasswd" {
  value = "${lookup(var.scmmap, "scm_passwd")}"
}
