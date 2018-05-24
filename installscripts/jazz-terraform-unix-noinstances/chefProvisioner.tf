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

  # Update git branch and repo in jenkins cookbook
  provisioner "local-exec" {
    command = "sed -i 's|default\\['git_branch'\\].*.|default\\['git_branch'\\]='${var.github_branch}'|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['git_repo'\\].*.|default\\['git_repo'\\]='${var.github_repo}'|g' ${var.jenkinsattribsfile}"
  }

  # Update AWS credentials in Jenkins Chef cookbook attributes
  provisioner "local-exec" {
    command = "sed -i 's|default\\['aws_access_key'\\].*.|default\\['aws_access_key'\\]='${var.aws_access_key}'|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['aws_secret_key'\\].*.|default\\['aws_secret_key'\\]='${var.aws_secret_key}'|g' ${var.jenkinsattribsfile}"
  }

  # Update cognito attribs in Jenkins Chef cookbook attributes
  provisioner "local-exec" {
    command = "sed -i 's|default\\['cognitouser'\\].*.|default\\['cognitouser'\\]='${var.cognito_pool_username}'|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['cognitopassword'\\].*.|default\\['cognitopassword'\\]='${var.cognito_pool_password}'|g' ${var.jenkinsattribsfile}"
  }

  #Update Gitlab attribs in Jenkins Chef cookbook attributes
  provisioner "local-exec" {
    command = "sed -i 's|default\\['gitlabuser'\\].*.|default\\['gitlabuser'\\]='${lookup(var.scmmap, "scm_username")}'|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['gitlabpassword'\\].*.|default\\['gitlabpassword'\\]='${lookup(var.scmmap, "scm_passwd")}'|g' ${var.jenkinsattribsfile}"
  }

  #Update Jenkins attribs in Jenkins Chef cookbook attributes
  provisioner "local-exec" {
    command = "sed -i 's|default\\['bbuser'\\].*.|default\\['bbuser'\\]='${lookup(var.scmmap, "scm_username")}'|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|default\\['bbpassword'\\].*.|default\\['bbpassword'\\]='${lookup(var.scmmap, "scm_passwd")}'|g' ${var.jenkinsattribsfile}"
  }

  provisioner "local-exec" {
    command = "sed -i 's|jenkinsuser:jenkinspasswd|${lookup(var.jenkinsservermap, "jenkinsuser")}:${lookup(var.jenkinsservermap, "jenkinspasswd")}|g' ${var.cookbooksSourceDir}/jenkins/files/default/authfile"
  }

  #END chef cookbook edits

  #Note that because the Terraform SSH connector is weird, we must manually create this directory
  #on the remote machine here *before* we copy things to it.
  provisioner "remote-exec" {
    inline = "mkdir -p ${var.chefDestDir}"
  }

  #Copy the chef playbooks and config over to the remote Jenkins server
  provisioner "file" {
    source      = "${var.policyfileSource}"
    destination = "${var.chefDestDir}/"
  }

  provisioner "file" {
    source      = "${var.cookbooksSourceDir}"
    destination = "${var.chefDestDir}/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh ${var.chefDestDir}/cookbooks/installChef.sh",
      "chef install ${chefDestDir}/Policyfile.rb",
      "chef export ${chefDestDir}/chef-export",
      "cd ${chefDestDir}/chef-export && chef-client -z"
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
