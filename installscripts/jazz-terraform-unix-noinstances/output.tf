#
# This resource will add necessary setting needed for the user into stack_details.json
#
resource "null_resource" "outputVariables" { 
  provisioner "local-exec" {
    command = "touch stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo { > stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"jenkins_elb\" : \"http://${lookup(var.jenkinsservermap, "jenkins_elb")}\",>> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"jenkins_username\" : \"${lookup(var.jenkinsservermap, "jenkinsuser")}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"jenkins_password\" : \"${lookup(var.jenkinsservermap, "jenkinspasswd")}\", >> stack_details.json"
  } 
  provisioner "local-exec" {
    command = "echo -e \"jenkins_subnet\" : \"${lookup(var.jenkinsservermap, "jenkins_subnet")}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"jazz_home\" : \"http://${aws_cloudfront_distribution.jazz.domain_name}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"jazz_admin_username\" : \"${var.cognito_pool_username}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"jazz_admin_password\" : \"${var.cognito_pool_password}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"region\" : \"${var.region}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"api_endpoint\" : \"https://${aws_api_gateway_rest_api.jazz-prod.id}.execute-api.${var.region}.amazonaws.com/prod\", >> stack_details.json"
  }  
}

resource "null_resource" "outputVariablesBB" {
  depends_on = ["null_resource.outputVariables"]
  count = "${var.scmbb}"

  provisioner "local-exec" {
    command = "echo -e \"bitbucket_elb\" : \"http://${lookup(var.scmmap, "scm_elb")}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"bitbucket_home\" : \"${lookup(var.scmmap, "scm_publicip")}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"bitbucket_username\" : \"${lookup(var.scmmap, "scm_username")}\",  >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"bitbucket_password\" : \"${lookup(var.scmmap, "scm_passwd")}\"  >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo } >> stack_details.json"
  }
}

resource "null_resource" "outputVariablesGitlab" {
  depends_on = ["null_resource.outputVariables"]
  count = "${var.scmgitlab}"

  provisioner "local-exec" {
    command = "echo -e \"gitlab_home\" : \"http://${lookup(var.scmmap, "scm_publicip")}\", >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"gitlab_username\" : \"${lookup(var.scmmap, "scm_username")}\",  >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo -e \"gitlab_password\" : \"${lookup(var.scmmap, "scm_passwd")}\"  >> stack_details.json"
  }
  provisioner "local-exec" {
    command = "echo } >> stack_details.json"
  }
}
