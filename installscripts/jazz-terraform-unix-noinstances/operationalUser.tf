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
        "iam:GetRole",
        "iam:CreateRole",
        "apigateway:*",
        "lambda:*",
        "logs:*",
        "cloudfront:*",
        "cloudformation:ValidateTemplate",
        "kinesis:*",
        "sqs:*",
        "dynamodb:*",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "cloudformation:*"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:cloudformation:*:${data.aws_caller_identity.current.account_id}:stackset/${var.envPrefix}*:*",
          "arn:aws:cloudformation:*:${data.aws_caller_identity.current.account_id}:stack/${var.envPrefix}*/*"
      ]
    }
  ]
}
EOF
}
