#
# SES Resource
#
resource "null_resource" "ses_setup" {
    depends_on = ["null_resource.cognito_user_pool"]

    provisioner "local-exec" {
        command = "${var.ses_cmd} ${var.cognito_pool_username} ${var.region} ${var.jenkinsattribsfile} ${var.aws_access_key} ${var.aws_secret_key} ${var.envPrefix}"
    }
}
