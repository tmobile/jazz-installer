resource "null_resource" "updateGitlabJenkinsConfig" {
  # TODO drop depends_on = ["null_resource.postJenkinsConfiguration"]
  count = "${var.scmgitlab}"

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} TYPE gitlab ${var.jenkinsjsonpropsfile}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} PRIVATE_TOKEN ${lookup(var.scmmap, "scm_privatetoken")} ${var.jenkinsjsonpropsfile}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} BASE_URL ${lookup(var.scmmap, "scm_publicip")} ${var.jenkinsjsonpropsfile}"
  }
}
