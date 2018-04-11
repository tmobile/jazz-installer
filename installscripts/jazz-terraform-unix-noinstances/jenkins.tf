resource "null_resource" "update_jenkins_configs" {
  #Cloudfront
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} CLOUDFRONT_ORIGIN_ID ${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path} ${var.jenkinsjsonpropsfile}"
  }

  #Cognito
  provisioner "local-exec" {
    command = "${var.cognito_cmd} ${var.envPrefix} ${aws_cognito_user_pool.pool.id} ${aws_cognito_user_pool_client.client.id} ${var.cognito_pool_username} ${var.cognito_pool_password}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} USER_POOL_ID ${aws_cognito_user_pool.pool.id} ${var.jenkinsjsonpropsfile}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} CLIENT_ID ${aws_cognito_user_pool_client.client.id} ${var.jenkinsjsonpropsfile}"
  }
  #Elasticsearch
  provisioner "local-exec" {
    command = "${var.configureESEndpoint_cmd} ${aws_elasticsearch_domain.elasticsearch_domain.endpoint} ${var.region}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} ES_HOSTNAME ${aws_elasticsearch_domain.elasticsearch_domain.endpoint} ${var.jenkinsjsonpropsfile}"
  }
  #S3
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} API_DOC ${aws_s3_bucket.jazz_s3_api_doc.bucket} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.configureApikey_cmd} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-stag.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region} ${var.jenkinsjsonpropsfile} ${var.jenkinsattribsfile} ${var.envPrefix}"
  }
  provisioner "local-exec" {
    command = "${var.configureS3Names_cmd} ${aws_s3_bucket.oab-apis-deployment-dev.bucket} ${aws_s3_bucket.oab-apis-deployment-stg.bucket} ${aws_s3_bucket.oab-apis-deployment-prod.bucket} ${aws_s3_bucket.jazz-web.bucket} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} ROLEID ${aws_iam_role.lambda_role.arn}  ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} WEBSITE_DEV_BUCKET ${aws_s3_bucket.dev-serverless-static.bucket} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} WEBSITE_STG_BUCKET ${aws_s3_bucket.stg-serverless-static.bucket} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} WEBSITE_PROD_BUCKET ${aws_s3_bucket.prod-serverless-static.bucket} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} JAZZ_REGION ${var.region} ${var.jenkinsjsonpropsfile}"
  }

  #SES
  provisioner "local-exec" {
    command = "${var.ses_cmd} ${var.cognito_pool_username} ${var.region} ${var.jenkinsattribsfile} ${var.aws_access_key} ${var.aws_secret_key} ${var.envPrefix}"
  }
  #TODO SORT!
  provisioner "local-exec" {
    command = "${var.configureJenkinselb_cmd} ${lookup(var.jenkinsservermap, "jenkins_elb")} ${var.jenkinsattribsfile} ${lookup(var.jenkinsservermap, "jenkinsuser")} ${lookup(var.jenkinsservermap, "jenkinspasswd")}"
  }
  provisioner "local-exec" {
    command = "${var.configureJenkinsSSHUser_cmd} ${lookup(var.jenkinsservermap, "jenkins_ssh_login")} ${var.jenkinsattribsfile} ${var.jenkinsclientrbfile}"
  }
  provisioner "local-exec" {
    command = "${var.configurescmelb_cmd} ${var.scmbb} ${lookup(var.scmmap, "scm_elb")} ${var.jenkinsattribsfile} ${var.jenkinsjsonpropsfile} ${var.scmclient_cmd}"
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
}
