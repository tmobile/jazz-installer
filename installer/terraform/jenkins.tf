resource "null_resource" "update_jenkins_configs" {
  depends_on = ["aws_cognito_user_pool_domain.domain", "null_resource.health_check_kibana"]

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

  #KINESIS
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {KINESIS_LOGS_STREAM_DEV} ${aws_kinesis_stream.logs_stream_dev.arn} ${var.jenkinsjsonpropsfile} BY_VALUE"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {KINESIS_LOGS_STREAM_STG} ${aws_kinesis_stream.logs_stream_stg.arn} ${var.jenkinsjsonpropsfile} BY_VALUE"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {KINESIS_LOGS_STREAM_PROD} ${aws_kinesis_stream.logs_stream_prod.arn} ${var.jenkinsjsonpropsfile} BY_VALUE"
  }

  #Elasticsearch
  provisioner "local-exec" {
    command = "${var.configureESEndpoint_cmd} ${format("http://%s:%s", join(" ", aws_lb.alb_ecs_es_kibana.*.dns_name), var.es_port_def)} ${format("http://%s:%s", join(" ", aws_lb.alb_ecs_es_kibana.*.dns_name), var.kibana_port_def)}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} ES_HOSTNAME ${aws_lb.alb_ecs_es_kibana.dns_name} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} ES_PORT ${var.es_port_def} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} KIBANA_HOSTNAME ${format("http://%s:%s", join(" ", aws_lb.alb_ecs_es_kibana.*.dns_name), var.kibana_port_def)} ${var.jenkinsjsonpropsfile}"
  }
  #TODO why do we need these following to values in addition to the previous ones?
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {AWS_STG_API_ID_JAZZ} ${aws_api_gateway_rest_api.jazz-stg.id} ${var.jenkinsjsonpropsfile} BY_VALUE"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} {AWS_PROD_API_ID_JAZZ} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.jenkinsjsonpropsfile} BY_VALUE"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} INSTANCE_PREFIX ${var.envPrefix} ${var.jenkinsjsonpropsfile}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} LAMBDA_EXECUTION_ROLE ${var.envPrefix}_basic_execution ${var.jenkinsjsonpropsfile}"
  }

  #S3
  # TODO Bug
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} API_DOC ${aws_s3_bucket.jazz_s3_api_doc.bucket} ${var.jenkinsjsonpropsfile}"
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} BUCKET_WEB ${aws_s3_bucket.jazz-web.bucket} ${var.jenkinsjsonpropsfile}"
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
    command = "${var.ses_cmd} ${var.cognito_pool_username} ${var.region} ${var.envPrefix}"
  }

  #TODO SORT!
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} STACK_ADMIN ${var.cognito_pool_username} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} STACK_PASSWORD ${var.cognito_pool_password} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} ACCOUNTID ${var.jazz_accountid} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} REGION ${var.region} ${var.jenkinsjsonpropsfile}"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} TAGS \"${var.aws_tags}\" ${var.jenkinsjsonpropsfile} ARRAY"
  }
  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} DOCKERIZED ${var.dockerizedJenkins == 1 ? "true": "false" } ${var.jenkinsjsonpropsfile} ARRAY"
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
