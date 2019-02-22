# Create a role for the Lambda function to exec under
resource "aws_iam_role" "apigee-lambda-role" {
  name = "${var.env_prefix}-jazz-apigee-lambda"
  path = "/jazz/${var.env_prefix}/system/roles/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach a policy to the lambda function role that lets it exec any lambda funcs
# in this region that were installed under this account
resource "aws_iam_role_policy" "apigee-lambda-policy" {
  name = "${var.env_prefix}-jazz-apigee-lambda"
  role = "${aws_iam_role.apigee-lambda-role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:${var.region}:${var.jazz_aws_accountid}:*"
    },
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "arn:aws:lambda:${var.region}:${var.jazz_aws_accountid}:*"
    }
  ]
}
EOF
}

#Create a new IAM service user for Apigee to use
#We will hand the creds for this service account off to Apigee.
resource "aws_iam_user" "apigee-proxy-user" {
  name = "${var.env_prefix}-jazz-apigee-proxy-lambda"
  path = "/jazz/${var.env_prefix}/system/"
  force_destroy = true
}

resource "aws_iam_access_key" "apigee-proxy-user-key" {
  user = "${aws_iam_user.apigee-proxy-user.name}"
}

#The IAM user we're creating should *only* be able to exec the Apigee proxy function
#we're creating
resource "aws_iam_user_policy" "apigee-lambda-exec" {
  name = "${var.env_prefix}-jazz-apigee-proxy-lambda-exec"
  user = "${aws_iam_user.apigee-proxy-user.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Effect": "Allow",
      "Resource": "${var.gateway_func_arn}"
    }
  ]
}
EOF
}

output "apigee-lambda-user" {
  value = "${aws_iam_access_key.apigee-proxy-user-key.user}"
}

#TODO This will store the Apigee user secret key in the Terraform state file on disk
#this is not optimal but requiring the user to set up a PGP key to encrypt it is too complex for now
output "apigee-lambda-user-secret-key" {
  value = "${aws_iam_access_key.apigee-proxy-user-key.secret}"
}

output "apigee-lambda-user-id" {
  value = "${aws_iam_access_key.apigee-proxy-user-key.id}"
}

output "apigee-lambda-gateway-func-arn" {
  value = "${var.gateway_func_arn}"
}

# TODO remove when Terraform import bug fixed
output "apigee-lambda-gateway-role-arn" {
  value = "${aws_iam_role.apigee-lambda-role.arn}"
}

# TODO remove when Terraform import bug fixed
# Because we want to restore the original func role on uninstall, save it here.
output "previous-role-arn" {
  value = "${var.previous_role_arn}"
}

#Generic installer output vars. These will be saved so you can query and provide them during uninstall.
output "installer-region" {
  value = "${var.region}"
}

output "env-prefix" {
  value = "${var.env_prefix}"
}
