resource "null_resource" "configureExistingJenkinsServer" {

  depends_on = ["aws_api_gateway_rest_api.jazz-dev","aws_s3_bucket.jazz-web","aws_iam_role.lambda_role","aws_elasticsearch_domain.elasticsearch_domain","null_resource.ses_setup" ]

  connection {
    host = "${lookup(var.jenkinsservermap, "jenkins_public_ip")}"
    user = "${lookup(var.jenkinsservermap, "jenkins_ssh_login")}"
    port = "${lookup(var.jenkinsservermap, "jenkins_ssh_port")}"
    type = "ssh"
    private_key = "${file("${lookup(var.jenkinsservermap, "jenkins_ssh_key")}")}"
  }

  provisioner "local-exec" {
    command = "${var.configureJenkinsSSHUser_cmd} ${lookup(var.jenkinsservermap, "jenkins_ssh_login")} ${var.jenkinsattribsfile} ${var.jenkinsclientrbfile}"
  }
  provisioner "local-exec" {
    command = "${var.configureJenkinselb_cmd} ${lookup(var.jenkinsservermap, "jenkins_elb")} ${var.jenkinsattribsfile} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")}"
  }
  provisioner "local-exec" {
    command = "${var.configureJazzCore_cmd} ${var.envPrefix} ${var.cognito_pool_username}"
  }
  provisioner "local-exec" {
    command = "${var.configurescmelb_cmd} ${var.scmbb} ${lookup(var.scmmap, "scm_elb")} ${var.jenkinsattribsfile} ${var.jenkinsjsonpropsfile} ${var.scmclient_cmd}"
  }

  #BEGIN chef cookbook edits TODO consider moving these to their own .tf file
  #Because we have to provision a preexisting machine here and can't use the terraform ses command,
  #we must use sed to insert AWS creds from the provisioner environment into a script chef will run later, before we copy the cookbook to the remote box.
  provisioner "local-exec" {
    command = "sed -i 's/AWS_ACCESS_KEY=.*.$/AWS_ACCESS_KEY='${var.aws_access_key}'/g' ${var.cookbooksDir}/jenkins/files/credentials/aws.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's#AWS_SECRET_KEY=.*.$#AWS_SECRET_KEY='${var.aws_secret_key}'#g' ${var.cookbooksDir}/jenkins/files/credentials/aws.sh"
  }

  # Update git branch in jenkins cookbook
  provisioner "local-exec" {
    command = "sed -i 's|default\\['git_branch'\\].*.|default\\['git_branch'\\]='${var.github_branch}'|g' ${var.cookbooksDir}/jenkins/attributes/default.rb"
  }


  # Update cognito script in cookbook
  provisioner "local-exec" {
    command = "sed -i 's|<username>cognitouser</username>|<username>${var.cognito_pool_username}</username>|g' ${var.cookbooksDir}/jenkins/files/credentials/cognitouser.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's|<password>cognitopasswd</password>|<password>${var.cognito_pool_password}</password>|g' ${var.cookbooksDir}/jenkins/files/credentials/cognitouser.sh"
  }

  #Update Jenkins script in cookbook
  provisioner "local-exec" {
    command = "sed -i 's|<username>bitbucketuser</username>|<username>${lookup(var.scmmap, "scm_username")}</username>|g' ${var.cookbooksDir}/jenkins/files/credentials/jenkins1.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's|<password>bitbucketpasswd</password>|<password>${lookup(var.scmmap, "scm_passwd")}</password>|g' ${var.cookbooksDir}/jenkins/files/credentials/jenkins1.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's|jenkinsuser:jenkinspasswd|${lookup(var.jenkinsservermap, "jenkinsuser")}:${lookup(var.jenkinsservermap, "jenkinspasswd")}|g' ${var.cookbooksDir}/jenkins/files/default/authfile"
  }
  #Update Gitlab script in cookbook
  provisioner "local-exec" {
    command = "sed -i 's|<username>gitlabuser</username>|<username>${lookup(var.scmmap, "scm_username")}</username>|g' ${var.cookbooksDir}/jenkins/files/credentials/gitlab-user.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's|<password>gitlabpassword</password>|<password>${lookup(var.scmmap, "scm_passwd")}</password>|g' ${var.cookbooksDir}/jenkins/files/credentials/gitlab-user.sh"
  }


  #END chef cookbook edits

  #Copy the chef playbooks and config over to the remote Jenkins server
  provisioner "file" {
    source      = "${var.cookbooksDir}"
    destination = "~/cookbooks"
  }

  provisioner "file" {
    source      = "${var.chefconfigDir}"
    destination = "~/chefconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh ~/cookbooks/installChef.sh",
      "curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/local/bin/jq",
      "sudo chmod 755 /usr/local/bin/jq",
      "cat ~/cookbooks/jenkins/files/plugins/plugins0* > plugins.tar",
      "chmod 777 plugins.tar",
      "sudo tar -xf plugins.tar -C /var/lib/jenkins/",
      "curl -O https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py",
      "sudo chmod -R o+w /usr/lib/python2.7/* /usr/bin/",
      "sudo chef-client --local-mode -c ~/chefconfig/jenkins_client.rb -j ~/chefconfig/node-jenkinsserver-packages.json"
    ]
  }

  provisioner "local-exec" {
    command = "sed -i 's/\"jenkins_username\"/\"${lookup(var.jenkinsservermap, "jenkinsuser")}\"/g' ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} JENKINS_PASSWORD ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "sed -i 's/\"scm_username\"/\"${lookup(var.scmmap, "scm_username")}\"/g' ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} PASSWORD ${lookup(var.scmmap, "scm_passwd")} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} ADMIN ${var.cognito_pool_username} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} PASSWD ${var.cognito_pool_password} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} ACCOUNTID ${var.jazz_accountid} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} REGION ${var.region} ${var.jenkinsjsonpropsfile}"
  }
  // Modifying subnet replacement before copying cookbooks to Jenkins server.
  provisioner "local-exec" {
    command = "${var.configureSubnet_cmd} ${lookup(var.jenkinsservermap, "jenkins_security_group")} ${lookup(var.jenkinsservermap, "jenkins_subnet")} ${var.envPrefix} ${var.jenkinsjsonpropsfile}"
  }

  provisioner "file" {
    source      = "${var.cookbooksDir}"
    destination = "~/cookbooks"
  }

  provisioner "file" {
    source      = "${var.cookbooksDir}/jenkins/recipes"
    destination = "~/cookbooks/jenkins"
  }
  provisioner "file" {
    source      = "${var.cookbooksDir}/jenkins/files/default"
    destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
    source      = "${var.cookbooksDir}/jenkins/files/jobs"
    destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
    source      = "${var.cookbooksDir}/jenkins/files/node"
    destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
    source      = "${var.cookbooksDir}/jenkins/files/scriptapproval"
    destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
    source      = "${var.cookbooksDir}/jenkins/files/credentials"
    destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
    source      = "${var.cookbooksDir}/jenkins/attributes"
    destination = "~/cookbooks/jenkins"
  }
  provisioner "file" {
    source      = "${var.cookbooksDir}/jenkins/attributes/"
    destination = "~/cookbooks/blankJenkins/attributes/"
  }

  provisioner "file" {
    source      = "${var.chefconfigDir}/"
    destination = "~/chefconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chef-client --local-mode -c ~/chefconfig/jenkins_client.rb --override-runlist blankJenkins::configureblankjenkins"
    ]
  }

  provisioner "local-exec" {
    command = "${var.modifyCodebase_cmd}  ${lookup(var.jenkinsservermap, "jenkins_security_group")} ${lookup(var.jenkinsservermap, "jenkins_subnet")} ${aws_iam_role.lambda_role.arn} ${var.region} ${var.envPrefix} ${var.cognito_pool_username}"
  }

  // Injecting bootstrap variables into Jazz-core Jenkinsfiles*
  provisioner "local-exec" {
    command = "${var.injectingBootstrapToJenkinsfiles_cmd} ${lookup(var.scmmap, "scm_elb")} ${lookup(var.scmmap, "scm_type")}"
  }


}

// Create Projects in Bitbucket. Will be executed only if the SCM is Bitbucket.
resource "null_resource" "createProjectsInBB" {
  depends_on = ["null_resource.configureExistingJenkinsServer","aws_elasticsearch_domain.elasticsearch_domain"]
  count = "${var.scmbb}"

  provisioner "local-exec" {
    command = "${var.scmclient_cmd} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")}"
  }
}

// Copy the jazz-build-module to SLF in SCM
resource "null_resource" "copyJazzBuildModule" {
  depends_on = ["null_resource.configureExistingJenkinsServer","aws_elasticsearch_domain.elasticsearch_domain","null_resource.createProjectsInBB"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${lookup(var.scmmap, "scm_elb")} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${lookup(var.scmmap, "scm_privatetoken")} ${lookup(var.scmmap, "scm_slfid")} ${lookup(var.scmmap, "scm_type")}  ${lookup(var.jenkinsservermap, "jenkins_elb")} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} jazz-build-module"
  }
}

// Configure jazz-installer-vars.json and push it to SLF/jazz-build-module
resource "null_resource" "configureJazzBuildModule" {
  depends_on = ["null_resource.copyJazzBuildModule"]

  connection {
    host = "${lookup(var.jenkinsservermap, "jenkins_public_ip")}"
    user = "${lookup(var.jenkinsservermap, "jenkins_ssh_login")}"
    port = "${lookup(var.jenkinsservermap, "jenkins_ssh_port")}"
    type = "ssh"
    port = "${lookup(var.jenkinsservermap, "jenkins_ssh_port")}"
    private_key = "${file("${lookup(var.jenkinsservermap, "jenkins_ssh_key")}")}"
  }
  provisioner "remote-exec"{
    inline = [
      "git clone http://${lookup(var.scmmap, "scm_username")}:${lookup(var.scmmap, "scm_passwd")}@${lookup(var.scmmap, "scm_elb")}${lookup(var.scmmap, "scm_pathext")}/slf/jazz-build-module.git",
      "cd jazz-build-module",
      "cp ~/cookbooks/jenkins/files/node/jazz-installer-vars.json .",
      "git add jazz-installer-vars.json",
      "git config --global user.email ${var.cognito_pool_username}",
      "git commit -m 'Adding Json file to repo'",
      "git push -u origin master",
      "cd ..",
      "sudo rm -rf jazz-build-module" ]
  }
}

// Push all other repos to SLF
resource "null_resource" "configureSCMRepos" {
  depends_on = ["null_resource.configureJazzBuildModule"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${lookup(var.scmmap, "scm_elb")} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${lookup(var.scmmap, "scm_privatetoken")} ${lookup(var.scmmap, "scm_slfid")} ${lookup(var.scmmap, "scm_type")} ${lookup(var.jenkinsservermap, "jenkins_elb")} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")}"
  }
}
