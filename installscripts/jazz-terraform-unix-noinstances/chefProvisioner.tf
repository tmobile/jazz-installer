resource "null_resource" "chef_provision_jenkins_server" {
  #TODO verify s3 dependency is valid
  depends_on = ["aws_s3_bucket.jazz-web", "null_resource.update_jenkins_configs"]
  connection {
    host = "${lookup(var.jenkinsservermap, "jenkins_public_ip")}"
    user = "${lookup(var.jenkinsservermap, "jenkins_ssh_login")}"
    port = "${lookup(var.jenkinsservermap, "jenkins_ssh_port")}"
    type = "ssh"
    private_key = "${file("${lookup(var.jenkinsservermap, "jenkins_ssh_key")}")}"
  }

  provisioner "local-exec" {
    command = "${var.configureJazzCore_cmd} ${var.envPrefix} ${var.cognito_pool_username}"
  }

  #BEGIN chef cookbook edits TODO consider moving these to their own .tf file
  #Because we have to provision a preexisting machine here and can't use the terraform ses command,
  #we must use sed to insert AWS creds from the provisioner environment into a script chef will run later, before we copy the cookbook to the remote box.
  provisioner "local-exec" {
    command = "sed -i 's/AWS_ACCESS_KEY=.*.$/AWS_ACCESS_KEY='${var.aws_access_key}'/g' ${var.cookbooksSourceDir}/jenkins/files/credentials/aws.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's#AWS_SECRET_KEY=.*.$#AWS_SECRET_KEY='${var.aws_secret_key}'#g' ${var.cookbooksSourceDir}/jenkins/files/credentials/aws.sh"
  }

  # Update git branch and repo in jenkins cookbook
  provisioner "local-exec" {
    command = "sed -i 's|default\\['git_branch'\\].*.|default\\['git_branch'\\]='${var.github_branch}'|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['git_repo'\\].*.|default\\['git_repo'\\]='${var.github_repo}'|g' ${var.jenkinsattribsfile}"
  }

  # Update cognito script in cookbook
  provisioner "local-exec" {
    command = "sed -i 's|<username>cognitouser</username>|<username>${var.cognito_pool_username}</username>|g' ${var.cookbooksSourceDir}/jenkins/files/credentials/cognitouser.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's|<password>cognitopasswd</password>|<password>${var.cognito_pool_password}</password>|g' ${var.cookbooksSourceDir}/jenkins/files/credentials/cognitouser.sh"
  }

  #Update Jenkins script in cookbook
  provisioner "local-exec" {
    command = "sed -i 's|<username>bitbucketuser</username>|<username>${lookup(var.scmmap, "scm_username")}</username>|g' ${var.cookbooksSourceDir}/jenkins/files/credentials/jenkins1.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's|<password>bitbucketpasswd</password>|<password>${lookup(var.scmmap, "scm_passwd")}</password>|g' ${var.cookbooksSourceDir}/jenkins/files/credentials/jenkins1.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's|jenkinsuser:jenkinspasswd|${lookup(var.jenkinsservermap, "jenkinsuser")}:${lookup(var.jenkinsservermap, "jenkinspasswd")}|g' ${var.cookbooksSourceDir}/jenkins/files/default/authfile"
  }

  #Update Gitlab script in cookbook
  provisioner "local-exec" {
    command = "sed -i 's|<username>gitlabuser</username>|<username>${lookup(var.scmmap, "scm_username")}</username>|g' ${var.cookbooksSourceDir}/jenkins/files/credentials/gitlab-user.sh"
  }

  provisioner "local-exec" {
    command = "sed -i 's|<password>gitlabpassword</password>|<password>${lookup(var.scmmap, "scm_passwd")}</password>|g' ${var.cookbooksSourceDir}/jenkins/files/credentials/gitlab-user.sh"
  }
  #END chef cookbook edits

  #Copy the chef playbooks and config over to the remote Jenkins server

  provisioner "file" {
    source      = "${var.chefconfigSourceDir}"
    destination = "${var.chefDestDir}/"
  }

  provisioner "file" {
    source      = "${var.cookbooksSourceDir}"
    destination = "${var.chefDestDir}/cookbooks/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh ${var.chefDestDir}/cookbooks/installChef.sh",
      "sudo curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/local/bin/jq",
      "sudo chmod 755 /usr/local/bin/jq",
      "cat ${var.chefDestDir}/cookbooks/jenkins/files/plugins/plugins0* > plugins.tar",
      "chmod 777 plugins.tar",
      "sudo tar -xf plugins.tar -C /var/lib/jenkins/",
      "curl -O https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py",
      "sudo chmod -R o+w /usr/lib/python2.7/* /usr/bin/",
      "sudo chef-client --local-mode --config-option cookbook_path='${var.chefDestDir}/cookbooks' -j ${var.chefDestDir}/chefconfig/node-jenkinsserver-packages.json"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chef-client --local-mode --config-option cookbook_path='${var.chefDestDir}/cookbooks' --override-runlist jenkins::configurejenkins"
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
