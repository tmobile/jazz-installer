resource "aws_api_gateway_rest_api" "jazz-dev" {
  name        = "${var.envPrefix}-dev"
  description = "DEV API Gateway"
}

resource "aws_api_gateway_rest_api" "jazz-stg" {
  name        = "${var.envPrefix}-stg"
  description = "STG API Gateway"
}

resource "aws_api_gateway_rest_api" "jazz-prod" {
  name        = "${var.envPrefix}-prod"
  description = "PROD API Gateway"

  provisioner "local-exec" {
    command = "rm -rf jazz-core"
  }
  provisioner "local-exec" {
    command = "git clone -b ${var.github_branch} ${var.github_repo} jazz-core --depth 1"

  }
  provisioner "local-exec" {
    command = "${var.configureApikey_cmd} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-stg.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.jenkinsjsonpropsfile} ${var.jenkinsattribsfile} ${var.envPrefix}"
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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "kinesisaccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3fullaccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "cognitopoweruser" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.envPrefix}_basic_execution"
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
}
