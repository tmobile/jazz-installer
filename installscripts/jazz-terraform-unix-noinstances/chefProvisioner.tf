resource "null_resource" "updateJenkinsChefCookbook" {
  # Only existing Jenkins servers need a cookbook
  count = "${1-var.dockerizedJenkins}"

  #TODO verify s3 dependency is valid
  depends_on = ["aws_s3_bucket.jazz-web"]

  # Update git branch and repo in jenkins cookbook
  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''git_branch'\\''\\].*.|default\\['\\''git_branch'\\''\\]='\\''${var.github_branch}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''git_repo'\\''\\].*.|default\\['\\''git_repo'\\''\\]='\\''${var.github_repo}'\\''|g' ${var.jenkinsattribsfile}"
  }

  # Update AWS credentials in Jenkins Chef cookbook attributes
  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''aws_access_key'\\''\\].*.|default\\['\\''aws_access_key'\\''\\]='\\''${aws_iam_access_key.operational_key.id}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''aws_secret_key'\\''\\].*.|default\\['\\''aws_secret_key'\\''\\]='\\''${aws_iam_access_key.operational_key.secret}'\\''|g' ${var.jenkinsattribsfile}"
  }

  # Update cognito attribs in Jenkins Chef cookbook attributes
  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''cognitouser'\\''\\].*.|default\\['\\''cognitouser'\\''\\]='\\''${var.cognito_pool_username}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''cognitopassword'\\''\\].*.|default\\['\\''cognitopassword'\\''\\]='\\''${var.cognito_pool_password}'\\''|g' ${var.jenkinsattribsfile}"
  }

  #Update Gitlab attribs in Jenkins Chef cookbook attributes
  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''gitlabuser'\\''\\].*.|default\\['\\''gitlabuser'\\''\\]='\\''${lookup(var.scmmap, "scm_username")}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''gitlabpassword'\\''\\].*.|default\\['\\''gitlabpassword'\\''\\]='\\''${lookup(var.scmmap, "scm_passwd")}'\\''|g' ${var.jenkinsattribsfile}"
  }

  #Update Jenkins attribs in Jenkins Chef cookbook attributes
  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''bbuser'\\''\\].*.|default\\['\\''bbuser'\\''\\]='\\''${lookup(var.scmmap, "scm_username")}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''bbpassword'\\''\\].*.|default\\['\\''bbpassword'\\''\\]='\\''${lookup(var.scmmap, "scm_passwd")}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''sonaruser'\\''\\].*.|default\\['\\''sonaruser'\\''\\]='\\''${lookup(var.codeqmap, "sonar_username")}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''sonarpassword'\\''\\].*.|default\\['\\''sonarpassword'\\''\\]='\\''${lookup(var.codeqmap, "sonar_passwd")}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''acl_db_user'\\''\\].*.|default\\['\\''acl_db_user'\\''\\]='\\''${var.acl_db_username}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['\\''acl_db_password'\\''\\].*.|default\\['\\''acl_db_password'\\''\\]='\\''${var.acl_db_password}'\\''|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|jenkinsuser:jenkinspasswd|${lookup(var.jenkinsservermap, "jenkinsuser")}:${lookup(var.jenkinsservermap, "jenkinspasswd")}|g' ${var.cookbooksSourceDir}/jenkins/files/default/authfile"
  }

  #END chef cookbook edits
}

resource "null_resource" "configureExistingJenkinsServer" {
  count = "${1-var.dockerizedJenkins}"
  depends_on = ["null_resource.updateJenkinsChefCookbook", "aws_s3_bucket.jazz-web", "null_resource.update_jenkins_configs"]

  connection {
    host = "${lookup(var.jenkinsservermap, "jenkins_public_ip")}"
    user = "${lookup(var.jenkinsservermap, "jenkins_ssh_login")}"
    port = "${lookup(var.jenkinsservermap, "jenkins_ssh_port")}"
    type = "ssh"
    private_key = "${file("${lookup(var.jenkinsservermap, "jenkins_ssh_key")}")}"
  }

  #Note that because the Terraform SSH connector is weird, we must manually create this directory
  #on the remote machine here *before* we copy things to it.
  provisioner "remote-exec" {
    inline = "mkdir -p ${var.chefDestDir}"
  }

  #Copy the chef playbooks over to the remote Jenkins server

  provisioner "file" {
    source      = "${var.cookbooksSourceDir}"
    destination = "${var.chefDestDir}/"
  }

  #TODO consider doing the export locally, so we only need to install `chef-client on the remote box`.
  provisioner "remote-exec" {
    inline = [
      "git clone ${var.contentRepo} --depth 1 ${var.chefDestDir}/jazz-content",
      "cp -r ${var.chefDestDir}/jazz-content/jenkins/files/. ${var.chefDestDir}/cookbooks/jenkins/files/default/",
      "sudo sh ${var.chefDestDir}/cookbooks/installChef.sh",
      "chef install ${var.chefDestDir}/cookbooks/Policyfile.rb",
      "chef export ${var.chefDestDir}/cookbooks/Policyfile.rb ${var.chefDestDir}/chef-export",
      "cd ${var.chefDestDir}/chef-export && sudo chef-client -z",
      "sudo rm -rf -f ${var.chefDestDir}"
    ]
  }
}

data "external" "gitlabcontainer" {
  count = "${var.scmgitlab}"
  program = ["bash", "${var.configureGitlab_cmd}"]

  query = {
    passwd = "${var.cognito_pool_password}"
    ip = "${aws_lb.alb_ecs_gitlab.dns_name}"
    gitlab_admin = "${lookup(var.scmmap, "scm_username")}"
  }
  depends_on = ["null_resource.health_check_gitlab"]
}

resource "null_resource" "configureCodeqDocker" {
  count = "${var.dockerizedSonarqube}"
  provisioner "local-exec" {
    command = "python ${var.configureCodeq_cmd} ${aws_lb.alb_ecs_codeq.dns_name} ${lookup(var.codeqmap, "sonar_passwd")}"
  }
  depends_on = ["null_resource.health_check_codeq"]
}

resource "null_resource" "configureJenkins" {
  depends_on = ["null_resource.health_check_jenkins", "null_resource.configureExistingJenkinsServer", "null_resource.update_jenkins_configs"]
  #Jenkins Cli process
  provisioner "local-exec" {
    command = "bash ${var.configureJenkinsCE_cmd} ${var.dockerizedJenkins == 1 ? join(" ", aws_lb.alb_ecs_jenkins.*.dns_name) : lookup(var.jenkinsservermap, "jenkins_elb") } ${var.cognito_pool_username} ${var.dockerizedJenkins} ${var.scmgitlab == 1 ? join(" ", aws_lb.alb_ecs_gitlab.*.dns_name) : lookup(var.scmmap, "scm_elb") } ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.scmgitlab == 1 ? join(" ", data.external.gitlabcontainer.*.result.token) : lookup(var.scmmap, "scm_privatetoken") } ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${lookup(var.scmmap, "scm_type")} ${lookup(var.codeqmap, "sonar_username")} ${lookup(var.codeqmap, "sonar_passwd")} ${aws_iam_access_key.operational_key.id} ${aws_iam_access_key.operational_key.secret} ${var.cognito_pool_password} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${var.acl_db_username} ${var.acl_db_password}"
  }
}

resource "null_resource" "postJenkinsConfiguration" {
  depends_on = ["null_resource.configureJenkins"]
  provisioner "local-exec" {
    command = "${var.modifyCodebase_cmd}  ${lookup(var.jenkinsservermap, "jenkins_security_group")} ${lookup(var.jenkinsservermap, "jenkins_subnet")} ${aws_iam_role.platform_role.arn} ${var.envPrefix} ${var.cognito_pool_username}"
  }
  // Injecting bootstrap variables into Jazz-core Jenkinsfiles*
  provisioner "local-exec" {
    command = "${var.injectingBootstrapToJenkinsfiles_cmd} ${var.dockerizedJenkins == 1 ? join(" ", aws_lb.alb_ecs_gitlab.*.dns_name) : lookup(var.scmmap, "scm_elb") } ${lookup(var.scmmap, "scm_type")}"
  }
}
