resource "null_resource" "updategitlabjenkinsconfig" {
  count = "${var.scmgitlab}"

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} TYPE gitlab ${var.jenkinsjsonpropsfile}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} PRIVATE_TOKEN ${join(" ", data.external.gitlabconfig.*.result.gitlab_token)} ${var.jenkinsjsonpropsfile}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} BASE_URL ${lookup(var.scmmap, "scm_publicip")} ${var.jenkinsjsonpropsfile}"
  }
}
