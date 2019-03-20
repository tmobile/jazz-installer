resource "null_resource" "update_jenkins_configs" {
  depends_on = ["aws_cognito_user_pool_domain.domain"]

  provisioner "local-exec" {
    command = "${var.configureApikey_cmd} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-stg.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.jenkinsjsonpropsfile} ${var.envPrefix}"
  }

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
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} API_DOC ${aws_s3_bucket.jazz_s3_api_doc.bucket} ${var.jenkinsjsonpropsfile}"
  }
  #SONAR
  provisioner "local-exec" {
    command = "${var.configureSonar_cmd} ${var.dockerizedSonarqube == 1 ? join(" ", aws_lb.alb_ecs_codeq.*.dns_name) : lookup(var.codeqmap, "sonar_server_elb") } ${var.codeq} ${var.jenkinsjsonpropsfile}"
  }
  #KINESIS
  provisioner "local-exec" {
    command = "${var.configureKinesis_cmd} ${aws_kinesis_stream.logs_stream_dev.arn} ${aws_kinesis_stream.logs_stream_stg.arn} ${aws_kinesis_stream.logs_stream_prod.arn} ${var.jenkinsjsonpropsfile}"
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
    command = "${var.configureApikey_cmd} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-stg.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.jenkinsjsonpropsfile} ${var.envPrefix}"
  }
  provisioner "local-exec" {
    command = "${var.configureS3Names_cmd} ${aws_s3_bucket.oab-apis-deployment-dev.bucket} ${aws_s3_bucket.oab-apis-deployment-stg.bucket} ${aws_s3_bucket.oab-apis-deployment-prod.bucket} ${aws_s3_bucket.jazz-web.bucket} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} PLATFORMSERVICES_ROLEID ${aws_iam_role.platform_role.arn}  ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} USERSERVICES_ROLEID ${aws_iam_role.lambda_role.arn}  ${var.jenkinsjsonpropsfile}"
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
    command = "${var.configureJenkinselb_cmd} ${lookup(var.jenkinsservermap, "jenkins_elb")} ${var.jenkinsattribsfile}"
  }
  provisioner "local-exec" {
    command = "${var.configureJenkinscontainer_cmd} ${var.dockerizedJenkins} ${var.jenkinsattribsfile}"
  }
  provisioner "local-exec" {
    command = "${var.configurescmelb_cmd} ${var.scmbb} ${lookup(var.scmmap, "scm_elb")} ${var.jenkinsattribsfile} ${var.jenkinsjsonpropsfile}"
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
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} TAGS \"${var.aws_tags}\" ${var.jenkinsjsonpropsfile} 'nostring'"
  }
  // Modifying subnet replacement before copying cookbooks to Jenkins server.
  provisioner "local-exec" {
    command = "${var.configureSubnet_cmd} ${lookup(var.jenkinsservermap, "jenkins_security_group")} ${lookup(var.jenkinsservermap, "jenkins_subnet")} ${var.envPrefix} ${var.jenkinsjsonpropsfile}"
  }
  // ACL
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} CLUSTER_READER_ENDPOINT ${aws_rds_cluster.casbin.reader_endpoint} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} CLUSTER_WRITER_ENDPOINT ${aws_rds_cluster.casbin.endpoint} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} ENDPOINT ${aws_rds_cluster_instance.casbin-instance.endpoint} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} PORT ${var.acl_db_port} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} NAME ${var.acl_db_name} ${var.jenkinsjsonpropsfile}"
  }
}
