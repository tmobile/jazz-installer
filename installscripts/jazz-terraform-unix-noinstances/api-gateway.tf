resource "aws_api_gateway_rest_api" "jazz-dev" {
  name        = "${var.envPrefix}-dev"
  description = "DEV API gateway"
}
resource "aws_api_gateway_rest_api" "jazz-stag" {
  name        = "${var.envPrefix}-stag"
  description = "STG API"
}

resource "aws_api_gateway_rest_api" "jazz-prod" {
  name        = "${var.envPrefix}-prod"
  description = "PROD API"
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
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    when = "destroy"
    on_failure = "continue"
    when = "destroy"
    on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonVPCCrossAccountNetworkInterfaceOperations"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = " aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
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
resource "aws_iam_role_policy_attachment" "networkadminaccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}
resource "aws_iam_role_policy_attachment" "vpccrossaccountaccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCCrossAccountNetworkInterfaceOperations"
}
resource "aws_iam_role_policy_attachment" "s3fullaccess" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "cognitopoweruser" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}
resource "aws_iam_role_policy_attachment" "vpcaccessexecution" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
