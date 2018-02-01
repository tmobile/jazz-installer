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
    command = "${var.configureJenkinselb_cmd} ${lookup(var.jenkinsservermap, "jenkins_elb")} ${var.jenkinsattribsfile} ${var.bitbucketclient_cmd} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")}"
  }
  provisioner "local-exec" {
    command = "${var.configureJazzCore_cmd} ${var.envPrefix} ${var.cognito_pool_username}"
  }
  provisioner "local-exec" {
    command = "${var.configurebitbucketelb_cmd} ${var.scmbb} ${lookup(var.bitbucketservermap, "bitbucket_elb")} ${var.jenkinsattribsfile} ${var.jenkinsjsonpropsfile} ${var.bitbucketclient_cmd}"
  }
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
           "sudo curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/local/bin/jq",
           "sudo chmod 755 /usr/local/bin/jq",
           "cat ~/cookbooks/jenkins/files/plugins/plugins0* > plugins.tar",
           "sudo chmod 777 plugins.tar",
           "sudo tar -xf plugins.tar -C /var/lib/jenkins/",
           "sudo curl -O https://bootstrap.pypa.io/get-pip.py&& sudo python get-pip.py",
           "sudo chmod -R o+w /usr/lib/python2.7/* /usr/bin/",
           "sudo chef-client --local-mode -c ~/chefconfig/jenkins_client.rb -j ~/chefconfig/node-jenkinsserver-packages.json"
     ]
   }


  provisioner "local-exec" {
	 command = "sed -i "s/\"jenkins_username\"/\"${lookup(var.jenkinsservermap, "jenkinsuser")}\"/g" ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} JENKINS_PASSWORD ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
	command = "sed -i "s/\"scm_username\"/\"${lookup(var.bitbucketservermap, "bitbucketuser")}\"/g" ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} PASSWORD ${lookup(var.bitbucketservermap, "bitbucketpasswd")} ${var.jenkinsjsonpropsfile}"
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
  
  provisioner "local-exec" {
    command = "${var.configureSubnet_cmd} ${lookup(var.jenkinsservermap, "jenkins_security_group")} ${lookup(var.jenkinsservermap, "jenkins_subnet")} ${var.envPrefix} ${var.jenkinsjsonpropsfile}"
  }
  
  // Injecting bootstrap variables into Jazz-core Jenkinsfiles*
  provisioner "local-exec" {
    command = "${var.injectingBootstrapToJenkinsfiles_cmd} ${lookup(var.bitbucketservermap, "bitbucket_elb")}"
  }


}

// Copy the jazz-build-module to SLF in SCM
resource "null_resource" "copyJazzBuildModule" {

  depends_on = ["null_resource.configureExistingJenkinsServer","aws_elasticsearch_domain.elasticsearch_domain"]
  count = "${var.scmbb}"

  provisioner "local-exec" {
    command = "${var.bitbucketclient_cmd} ${var.region} ${lookup(var.bitbucketservermap, "bitbucketuser")} ${lookup(var.bitbucketservermap, "bitbucketpasswd")} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} ${var.cognito_pool_username} jazz-build-module"
  }
}


resource "null_resource" "configureJazzBuildModule" {
// Configure jazz-installer-vars.json and push it to SLF/jazz-build-module
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
       "git clone http://${var.scmUsername}:${var.scmPasswd}@${var.scmELB}${var.scmPathExt}/slf/jazz-build-module.git",
       "cd jazz-build-module",
       "cp ~/cookbooks/jenkins/files/node/jazz-installer-vars.json .",
       "git add jazz-installer-vars.json",
       "git config --global user.email ${var.cognito_pool_username}",
       "git commit -m 'Adding Json file to repo'",
       "git push -u origin master",
       "cd ..",
       "sudo rm -rf jazz-build-module" ]
 }
  //This would be the last command which needs to be run which triggers the Jenkins Build deploy job
 provisioner "local-exec" {
    command = "curl  -X GET -u ${lookup(var.jenkinsservermap, "jenkinsuser")}:${lookup(var.jenkinsservermap, "jenkinspasswd")} http://${lookup(var.jenkinsservermap, "jenkins_elb")}/job/deploy-all-platform-services/buildWithParameters?token=dep-all-ps-71717&region=${var.region}"
  }
}

// Push all other repos to SLF
resource "null_resource" "configureExistingBitbucketServer" {

  depends_on = ["null_resource.configureJazzBuildModule"]

  provisioner "local-exec" {
    command = "${var.bitbucketpush_cmd} ${lookup(var.bitbucketservermap, "bitbucket_elb")}  ${lookup(var.bitbucketservermap, "bitbucketuser")} ${lookup(var.bitbucketservermap, "bitbucketpasswd")} ${var.cognito_pool_username}"
  }
}

resource "null_resource" "configureGitlabServer" {
  // Configure the trigger job
  depends_on = ["null_resource.configureExistingJenkinsServer","aws_elasticsearch_domain.elasticsearch_domain"]
  count = "${var.scmgitlab}"

  provisioner "local-exec" {
    command = "${var.gitlabPush_cmd} ${lookup(var.gitlabservermap, "gitlabtoken")} ${lookup(var.gitlabservermap, "gitlabcasid")} ${lookup(var.gitlabservermap, "gitlabuser")} ${lookup(var.gitlabservermap, "gitlabpasswd")} ${lookup(var.gitlabservermap, "gitlab_public_ip")}"
  }
}
