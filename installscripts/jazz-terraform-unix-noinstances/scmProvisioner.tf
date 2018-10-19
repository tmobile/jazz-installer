// Create Projects in Bitbucket. Will be executed only if the SCM is Bitbucket.
resource "null_resource" "createProjectsInBB" {
  # TODO drop depends_on = ["null_resource.postJenkinsConfiguration"]
  count = "${var.scmbb}"

  provisioner "local-exec" {
    command = "${var.scmclient_cmd} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${ lookup(var.scmmap, "scm_elb")} ${var.atlassian_jar_path}"
  }
}

// Copy the jazz-build-module to SLF in SCM
resource "null_resource" "copyJazzBuildModule" {
  count = "${1 - var.scmgitlab * var.dockerizedJenkins}"
  depends_on = ["null_resource.postJenkinsConfiguration", "null_resource.createProjectsInBB"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${lookup(var.scmmap, "scm_elb")} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${data.external.gitlabcontainer.result.token} ${data.external.gitlabcontainer.result.scm_slfid} ${lookup(var.scmmap, "scm_type")}  ${lookup(var.jenkinsservermap, "jenkins_elb")} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region} builds"
  }
}

resource "null_resource" "copyJazzBuildModule_dockerized" {
  count = "${var.scmgitlab * var.dockerizedJenkins}"
  depends_on = ["null_resource.postJenkinsConfiguration_gitlab"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${aws_lb.alb_ecs_gitlab.dns_name} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${data.external.gitlabcontainer.result.token} ${data.external.gitlabcontainer.result.scm_slfid} ${lookup(var.scmmap, "scm_type")}  ${aws_lb.alb_ecs.dns_name} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region} builds"
  }
}

// Configure jazz-installer-vars.json and push it to SLF/jazz-build-module
resource "null_resource" "configureJazzBuildModule" {
  count = "${1 - var.scmgitlab}"
  depends_on = ["null_resource.copyJazzBuildModule", "null_resource.update_jenkins_configs" ]
  provisioner "local-exec" {
    command = "${var.pushInstallervars_cmd} ${lookup(var.scmmap, "scm_username")} ${urlencode(lookup(var.scmmap, "scm_passwd"))} ${lookup(var.scmmap, "scm_elb")} ${lookup(var.scmmap, "scm_pathext")} ${var.cognito_pool_username}"
  }
}

resource "null_resource" "configureJazzBuildModule_gitlab" {
  count = "${var.scmgitlab}"
  depends_on = ["null_resource.copyJazzBuildModule_dockerized", "null_resource.update_jenkins_configs" ]
  provisioner "local-exec" {
    command = "${var.pushInstallervars_cmd} ${lookup(var.scmmap, "scm_username")} ${urlencode(lookup(var.scmmap, "scm_passwd"))} ${aws_lb.alb_ecs_gitlab.dns_name} ${lookup(var.scmmap, "scm_pathext")} ${var.cognito_pool_username}"
  }
}

// Push all other repos to SLF
resource "null_resource" "configureSCMRepos" {
  count = "${1 - var.scmgitlab * var.dockerizedJenkins}"
  depends_on = ["null_resource.configureJazzBuildModule"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${lookup(var.scmmap, "scm_elb")} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${data.external.gitlabcontainer.result.token} ${data.external.gitlabcontainer.result.scm_slfid} ${lookup(var.scmmap, "scm_type")} ${lookup(var.jenkinsservermap, "jenkins_elb")} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region}"
  }
}

resource "null_resource" "configureSCMRepos_dockerized" {
  count = "${var.scmgitlab * var.dockerizedJenkins}"
  depends_on = ["null_resource.configureJazzBuildModule_gitlab"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${aws_lb.alb_ecs_gitlab.dns_name} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${data.external.gitlabcontainer.result.token} ${data.external.gitlabcontainer.result.scm_slfid} ${lookup(var.scmmap, "scm_type")} ${aws_lb.alb_ecs.dns_name} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region}"
  }
}
