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
        "events:*",
        "ec2:DescribeVpcClassicLinkDnsSupport",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeVpcEndpointServices",
        "ec2:DescribeVpcEndpointServiceConfigurations",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeVpcEndpointConnectionNotifications",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcClassicLink",
        "ec2:ModifySubnetAttribute",
        "ec2:DescribeVpcEndpointServicePermissions",
        "ec2:DescribeSecurityGroupReferences",
        "ec2:DescribeVpcs",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeVpcEndpointConnections",
        "ec2:DescribeSubnets",
        "ec2:DescribeStaleSecurityGroups"
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
