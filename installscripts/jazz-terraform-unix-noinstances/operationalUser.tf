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
        "iam:ListPolicies",
        "iam:ListRoles",
        "apigateway:*",
        "lambda:*",
        "logs:*",
        "cloudfront:*",
        "kinesis:*",
        "sqs:*",
        "dynamodb:*",
        "s3:*",
        "cloudformation:*",
        "sns:*",
        "cloudwatch:*",
        "events:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "iam:GetRole",
        "iam:PassRole",
        "iam:GetPolicy",
        "iam:DeleteRolePolicy",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:UpdateRole",
        "iam:PutRolePolicy"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.envPrefix}*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.envPrefix}*"
      ]
    }
  ]
}
EOF
}
