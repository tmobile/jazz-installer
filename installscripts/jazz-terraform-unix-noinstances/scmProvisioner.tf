// Create Projects in Bitbucket. Will be executed only if the SCM is Bitbucket.
resource "null_resource" "createProjectsInBB" {
  # TODO drop depends_on = ["null_resource.chef_provision_jenkins_server"]
  count = "${var.scmbb}"

  provisioner "local-exec" {
    command = "${var.scmclient_cmd} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")}"
  }
}

// Copy the jazz-build-module to SLF in SCM
resource "null_resource" "copyJazzBuildModule" {
  depends_on = ["null_resource.chef_provision_jenkins_server","null_resource.createProjectsInBB"]

  provisioner "local-exec" {
    command = "${var.scmpush_cmd} ${lookup(var.scmmap, "scm_elb")} ${lookup(var.scmmap, "scm_username")} ${lookup(var.scmmap, "scm_passwd")} ${var.cognito_pool_username} ${lookup(var.scmmap, "scm_privatetoken")} ${lookup(var.scmmap, "scm_slfid")} ${lookup(var.scmmap, "scm_type")}  ${lookup(var.jenkinsservermap, "jenkins_elb")} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")} jazz-build-module"
  }
}

// Configure jazz-installer-vars.json and push it to SLF/jazz-build-module
resource "null_resource" "configureJazzBuildModule" {
  depends_on = ["null_resource.copyJazzBuildModule", "null_resource.update_jenkins_configs" ]

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
