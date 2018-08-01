data "archive_file" "apigee-gateway-zip" {
  type        = "zip"
  source_dir = "${path.module}/../jazz-apigee-proxy"
  output_path = "${path.module}/../jazz-apigee-proxy.zip"
}


resource "aws_iam_role" "iam_for_apigee_lambda" {
  name = "iam_for_apigee_lambda"

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

#TODO figure out how to build zip.
resource "aws_lambda_function" "jazz-apigee-proxy" {
  filename         = "${data.archive_file.apigee-gateway-zip.output_path}"
  function_name    = "jazz-apigee-proxy"
  role             = "${aws_iam_role.iam_for_apigee_lambda.arn}"
  handler          = "jazz-apigee-proxy.handler"
  source_code_hash = "${data.archive_file.apigee-gateway-zip.output_base64sha256}"
  runtime          = "nodejs8.10"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}
