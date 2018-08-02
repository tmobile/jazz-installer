# Zip up function for deploy
data "archive_file" "apigee-gateway-zip" {
  type        = "zip"
  source_dir = "${path.module}/../jazz-apigee-proxy"
  output_path = "${path.module}/../jazz-apigee-proxy.zip"
}

#TODO put env prefix in here..somehow?
# Create a role for the Lambda function to exec under
resource "aws_iam_role" "apigee_lambda_role" {
  name = "jazz_apigee_lambda"
  path = "/jazz/system/roles/"
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
resource "aws_iam_role_policy" "apigee_lambda_policy" {
  name = "jazz_apigee_lambda"
  role = "${aws_iam_role.apigee_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:InvokeFunction",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:lambda:${var.region}:${var.jazz_aws_accountid}:*"
    }
  ]
}
EOF
}

# Deploy the function with the correct role.
resource "aws_lambda_function" "jazz-apigee-proxy" {
  filename         = "${data.archive_file.apigee-gateway-zip.output_path}"
  function_name    = "jazz-apigee-proxy"
  role             = "${aws_iam_role.apigee_lambda_role.arn}"
  handler          = "jazz-apigee-proxy.handler"
  source_code_hash = "${data.archive_file.apigee-gateway-zip.output_base64sha256}"
  runtime          = "nodejs8.10"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}

#Create a new IAM service user for Apigee to use
#We will hand the creds for this service account off to Apigee.
resource "aws_iam_user" "apigee-proxy-user" {
  name = "jazz-apigee-proxy-lambda"
  path = "/jazz/system/"
  force_destroy = true
}

resource "aws_iam_access_key" "apigee-proxy-user-key" {
  user = "${aws_iam_user.apigee-proxy-user.name}"
}

#The IAM user we're creating should *only* be able to exec the Apigee proxy function
#we're creating
resource "aws_iam_user_policy" "apigee-lambda-exec" {
  name = "jazz-apigee-proxy-lambda-exec"
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
      "Resource": "${aws_lambda_function.jazz-apigee-proxy.arn}"
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
