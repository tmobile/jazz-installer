resource "aws_iam_user" "operational" {
  name = "${var.envPrefix}-operationaluser"
  path = "/system/"
}

resource "aws_iam_access_key" "operational_key" {
  user = "${aws_iam_user.operational.name}"
}

resource "aws_iam_user_policy" "operational_policy" {
  name = "${var.envPrefix}-operationaluser-policy"
  user = "${aws_iam_user.operational.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:PassRole",
        "dynamodb:*",
        "s3:*",
        "cloudformation:*",
        "apigateway:*",
        "lambda:*",
        "logs:*",
        "cloudfront:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
