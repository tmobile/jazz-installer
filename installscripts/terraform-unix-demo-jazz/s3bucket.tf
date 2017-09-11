resource "aws_s3_bucket" "cloudfrontlogs" {
  bucket_prefix="${var.envPrefix}-cloudfrontlogs-"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "${var.region}"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  provisioner "local-exec" {
    command = "${var.sets3acl_cmd} ${aws_s3_bucket.cloudfrontlogs.bucket}"
  }
  provisioner "local-exec" {
	when = "destroy"
    on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.cloudfrontlogs.bucket}  --recursive"
  }
}

resource "aws_s3_bucket" "oab-apis-deployment-dev" {
  bucket_prefix = "${var.envPrefix}-apis-deployment-dev-"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "${var.region}"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  provisioner "local-exec" {
    command = "${var.sets3acl_cmd} ${aws_s3_bucket.oab-apis-deployment-dev.bucket}"
  }
  provisioner "local-exec" {
	when = "destroy"
    on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.oab-apis-deployment-dev.bucket} --recursive"
  }

}
resource "aws_s3_bucket" "oab-apis-deployment-stg" {
  bucket_prefix = "${var.envPrefix}-apis-deployment-stg-"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "${var.region}"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  provisioner "local-exec" {
    command = "${var.sets3acl_cmd} ${aws_s3_bucket.oab-apis-deployment-stg.bucket}"
  }
  provisioner "local-exec" {
	when = "destroy"
	on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.oab-apis-deployment-stg.bucket} --recursive"
  }

}
resource "aws_s3_bucket" "oab-apis-deployment-prod" {
  bucket_prefix = "${var.envPrefix}-apis-deployment-prod-"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "${var.region}"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  provisioner "local-exec" {
    command = "${var.sets3acl_cmd} ${aws_s3_bucket.oab-apis-deployment-prod.bucket}"
  }
  provisioner "local-exec" {
	when = "destroy"
	on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.oab-apis-deployment-prod.bucket} --recursive"
  }
  
}

resource "aws_api_gateway_rest_api" "jazz-dev" {
  name        = "${var.envPrefix}-dev"
  description = "DEV API gateway for Tmobile demo "
}
resource "aws_api_gateway_rest_api" "jazz-stag" {
  name        = "${var.envPrefix}-stag"
  description = "STG API for Tmobile demo"
}
resource "aws_api_gateway_rest_api" "jazz-prod" {
  name        = "${var.envPrefix}-prod"
  description = "PROD API for Tmobile demo"
  provisioner "local-exec" {
    command = "git clone -b phase3-dev https://${var.github_username}:${var.github_password}@github.com/tmobile/jazz-core.git"
  }
  provisioner "local-exec" {
    command = "git clone https://${var.github_username}:${var.github_password}@github.com/tmobile/jazz-ui.git"
  }	
  provisioner "local-exec" {
    command = "${var.configureApikey_cmd} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-stag.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region} ${var.jenkinspropsfile}  ${var.jenkinsattribsfile} ${var.envPrefix}"
  }
}
resource "aws_s3_bucket" "jazz-web" {
  bucket_prefix = "${var.envPrefix}-web-"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "${var.region}"
  depends_on = ["aws_api_gateway_rest_api.jazz-prod" ]
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  website {
    index_document = "index.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }

  provisioner "local-exec" {
    command = "${var.sets3acl_cmd} ${aws_s3_bucket.jazz-web.bucket}"
  }
  provisioner "local-exec" {
    command = "${var.deployS3Webapp_cmd} ${aws_s3_bucket.jazz-web.bucket} ${var.region}"
  }  

  provisioner "local-exec" {
    command = "${var.configureS3Names_cmd} ${aws_s3_bucket.oab-apis-deployment-dev.bucket} ${aws_s3_bucket.oab-apis-deployment-stg.bucket} ${aws_s3_bucket.oab-apis-deployment-prod.bucket} ${aws_s3_bucket.cloudfrontlogs.bucket} ${aws_s3_bucket.jazz-web.bucket} ${var.jenkinspropsfile} "
  }

  provisioner "local-exec" {
	when = "destroy"
	on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.jazz-web.bucket}/ --recursive"
  }
  provisioner "local-exec" {
	when = "destroy"
	on_failure = "continue"
    command = "sudo rm -rf ./jazz-core ./jazz-core-bitbucket ./jazz-ui"
  }
}





resource "aws_iam_policy" "basic_execution_policy" {
  name        = "${var.envPrefix}_execution_aws_logs"
  path        = "/"
  description = "aws_logs access policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.envPrefix}_lambda2_basic_execution_1"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
		{
			"Sid": "",
			"Effect": "Allow",
			"Principal": {
						"Service": "apigateway.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		},
		{
			"Effect": "Allow",
			"Principal": {
						"Service": "lambda.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
   ]
}
EOF
  provisioner "local-exec" {
        when = "destroy"
	on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
  }
  provisioner "local-exec" {
        when = "destroy"
	on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn ${aws_iam_policy.basic_execution_policy.arn}"
  }
  provisioner "local-exec" {
        when = "destroy"
	on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess"
  }


}




resource "aws_iam_role_policy_attachment" "lambdafullaccess" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}
resource "aws_iam_role_policy_attachment" "apigatewayinvokefullAccess" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}
resource "aws_iam_role_policy_attachment" "cloudwatchlogaccess" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "${aws_iam_policy.basic_execution_policy.arn}"
}
resource "aws_iam_role_policy_attachment" "kinesisaccess" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

resource "aws_s3_bucket" "dev-serverless-static" {
  bucket_prefix = "${var.envPrefix}-dev-serverless-static-website-"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "${var.region}"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} WEBSITE_DEV_S3BUCKET ${aws_s3_bucket.dev-serverless-static.bucket} ${var.jenkinspropsfile}"
  }
  provisioner "local-exec" {
	when = "destroy"
	on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.dev-serverless-static.bucket} --recursive"
  }

}

resource "aws_s3_bucket" "stg-serverless-static" {
  bucket_prefix = "${var.envPrefix}-stg-serverless-static-website-"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "${var.region}"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} WEBSITE_STG_S3BUCKET ${aws_s3_bucket.stg-serverless-static.bucket} ${var.jenkinspropsfile}"
  }
  provisioner "local-exec" {
	when = "destroy"
	on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.stg-serverless-static.bucket} --recursive"
  }

}

resource "aws_s3_bucket" "prod-serverless-static" {
  bucket_prefix = "${var.envPrefix}-prod-serverless-static-website-"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "${var.region}"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  provisioner "local-exec" {
    command = "${var.modifyPropertyFile_cmd} WEBSITE_PROD_S3BUCKET ${aws_s3_bucket.prod-serverless-static.bucket} ${var.jenkinspropsfile}"
  }
  provisioner "local-exec" {
	when = "destroy"
	on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.prod-serverless-static.bucket} --recursive"
  }

}

resource "aws_iam_policy" "dev-serverless-static-policy" {
  name        = "${var.envPrefix}_dev_serverless_static_policy"
  path        = "/"
  description = "access policy to dev serverless static bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "${aws_s3_bucket.dev-serverless-static.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "stg-serverless-static-policy" {
  name        = "${var.envPrefix}_stg_serverless_static_policy"
  path        = "/"
  description = "access policy to stg serverless static bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "${aws_s3_bucket.stg-serverless-static.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "prod-serverless-static-policy" {
  name        = "${var.envPrefix}_prod_serverless_static_policy"
  path        = "/"
  description = "access policy to prod serverless static bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "${aws_s3_bucket.prod-serverless-static.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dev-serverless-static-bucket-policy-attachment" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "${dev-serverless-static-policy.policy.arn}"
	
resource "aws_iam_role_policy_attachment" "stg-serverless-static-bucket-policy-attachment" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "${stg-serverless-static-policy.policy.arn}"
	
resource "aws_iam_role_policy_attachment" "prod-serverless-static-bucket-policy-attachment" {
    role       = "${aws_iam_role.lambda_role.name}"
    policy_arn = "${prod-serverless-static-policy.policy.arn}"