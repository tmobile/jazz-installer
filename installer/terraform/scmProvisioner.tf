// Create Projects in Bitbucket. Will be executed only if the SCM is Bitbucket.
resource "null_resource" "createProjectsInBB" {
  # TODO drop depends_on = ["null_resource.postJenkinsConfiguration"]
  count = "${var.scmbb}"

  provisioner "local-exec" {
    command = "${var.scmclient_cmd} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${ lookup(var.scmmap, "scm_elb")} ${var.atlassian_jar_path}"
  }

  #If using BB, update the base URL as well
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} BASE_URL ${lookup(var.scmmap, "scm_elb")} ${var.jenkinsjsonpropsfile}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {SCM_TYPE} bitbucket ${var.jenkinsjsonpropsfile} BY_VALUE"
  }
}

// Copy the jazz-build-module to SLF in SCM
resource "null_resource" "copyJazzBuildModule" {
  depends_on = ["null_resource.pushconfig", "null_resource.postJenkinsConfiguration", "null_resource.createProjectsInBB", "null_resource.updategitlabjenkinsconfig"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${var.scmgitlab == 1 ? join(" ", aws_lb.alb_ecs_gitlab.*.dns_name) : lookup(var.scmmap, "scm_elb") } ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${var.scmgitlab == 1 ? join(" ", data.external.gitlabconfig.*.result.gitlab_token) : lookup(var.scmmap, "scm_privatetoken") } ${var.scmgitlab == 1 ? join(" ", data.external.gitlabconfig.*.result.gitlab_slfid) : lookup(var.scmmap, "scm_slfid") } ${lookup(var.scmmap, "scm_type")}  ${var.dockerizedJenkins == 1 ? join(" ", aws_lb.alb_ecs_jenkins.*.dns_name) : lookup(var.jenkinsservermap, "jenkins_elb") } ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region} builds"
  }
}

resource "null_resource" "pushconfig" {
  depends_on = ["null_resource.postJenkinsConfiguration"]
  provisioner "local-exec" {
    command = "python ${var.config_cmd} ${aws_dynamodb_table.installer_config_db.name} ${aws_dynamodb_table.installer_config_db.hash_key} ${var.envPrefix} ${var.jenkinsjsonpropsfile} ${var.region} ${var.jazz_accountid} ${aws_iam_role.platform_role.arn} ${aws_iam_role.lambda_role.arn} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${aws_api_gateway_rest_api.jazz-stg.id} ${aws_s3_bucket.oab-apis-deployment-dev.bucket} ${aws_s3_bucket.oab-apis-deployment-prod.bucket} ${aws_s3_bucket.oab-apis-deployment-stg.bucket} ${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path} ${var.dockerizedJenkins == 1 ? join(" ", aws_security_group.vpc_sg.*.id) : lookup(var.jenkinsservermap, "jenkins_security_group") } ${var.dockerizedJenkins == 1 ? join(",", aws_subnet.subnet_for_ecs_private.*.id) : lookup(var.jenkinsservermap, "jenkins_subnet") }"
  }
}

// Push all other repos to SLF
resource "null_resource" "configureSCMRepos" {
  depends_on = ["null_resource.copyJazzBuildModule"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${var.scmgitlab == 1 ? join(" ", aws_lb.alb_ecs_gitlab.*.dns_name) : lookup(var.scmmap, "scm_elb") } ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${var.scmgitlab == 1 ? join(" ", data.external.gitlabconfig.*.result.gitlab_token) : lookup(var.scmmap, "scm_privatetoken") } ${var.scmgitlab == 1 ? join(" ", data.external.gitlabconfig.*.result.gitlab_slfid) : lookup(var.scmmap, "scm_slfid") } ${lookup(var.scmmap, "scm_type")} ${var.dockerizedJenkins == 1 ? join(" ", aws_lb.alb_ecs_jenkins.*.dns_name) : lookup(var.jenkinsservermap, "jenkins_elb") } ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region}"
  }
}
