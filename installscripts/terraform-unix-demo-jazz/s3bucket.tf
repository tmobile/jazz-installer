resource "aws_s3_bucket" "cloudfrontlogs" {
  bucket = "${var.envPrefix}-cloudfrontlogs"
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
    command = "	aws s3 rm s3://${var.envPrefix}-cloudfrontlogs  --recursive"
  }
}

resource "aws_s3_bucket" "oab-apis-deployment-dev" {
  bucket = "${var.envPrefix}-apis-deployment-dev"
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
    command = "	aws s3 rm s3://${var.envPrefix}-apis-deployment-dev --recursive"
  }

}
resource "aws_s3_bucket" "oab-apis-deployment-stg" {
  bucket = "${var.envPrefix}-apis-deployment-stg"
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
    command = "	aws s3 rm s3://${var.envPrefix}-apis-deployment-stg --recursive"
  }

}
resource "aws_s3_bucket" "oab-apis-deployment-prod" {
  bucket = "${var.envPrefix}-apis-deployment-prod"
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
    command = "	aws s3 rm s3://${var.envPrefix}-apis-deployment-prod --recursive"
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
    command = "git clone https://ustharin:Tmobiledemo1@github.com/tmobile/jazz-core.git"
  }
  provisioner "local-exec" {
    command = "git clone https://ustharin:Tmobiledemo1@github.com/tmobile/jazz-ui.git"
  }	
  provisioner "local-exec" {
    command = "${var.configureApikey_cmd} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-stag.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region} ${var.jenkinspropsfile}  ${var.jenkinsattribsfile} ${var.envPrefix}"
  }
}
resource "aws_s3_bucket" "jazz-web" {
  bucket = "${var.envPrefix}-web"
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
	when = "destroy"
	on_failure = "continue"
    command = "	aws s3 rm s3://${aws_s3_bucket.jazz-web.bucket}/ --recursive"
  }
  provisioner "local-exec" {
	when = "destroy"
	on_failure = "continue"
    command = "sudo rm -rf ./jazz-core ./jazz-core-bitbucket"
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
