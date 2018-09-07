data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "oab-apis-deployment-dev" {
  bucket_prefix = "${var.envPrefix}-apis-deployment-dev-"
  request_payer = "BucketOwner"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags {
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
  }

  provisioner "local-exec" {
    command = "${var.sets3acl_cmd} ${aws_s3_bucket.oab-apis-deployment-dev.bucket} ${data.aws_canonical_user_id.current.id}"
  }

  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws s3 rm s3://${aws_s3_bucket.oab-apis-deployment-dev.bucket} --recursive"
  }
}
resource "aws_s3_bucket" "oab-apis-deployment-stg" {
  bucket_prefix = "${var.envPrefix}-apis-deployment-stg-"
  request_payer = "BucketOwner"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags {
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
  }
  provisioner "local-exec" {
    command = "${var.sets3acl_cmd} ${aws_s3_bucket.oab-apis-deployment-stg.bucket} ${data.aws_canonical_user_id.current.id}"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws s3 rm s3://${aws_s3_bucket.oab-apis-deployment-stg.bucket} --recursive"
  }
}
resource "aws_s3_bucket" "oab-apis-deployment-prod" {
  bucket_prefix = "${var.envPrefix}-apis-deployment-prod-"
  request_payer = "BucketOwner"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags {
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
  }
  provisioner "local-exec" {
    command = "${var.sets3acl_cmd} ${aws_s3_bucket.oab-apis-deployment-prod.bucket} ${data.aws_canonical_user_id.current.id}"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws s3 rm s3://${aws_s3_bucket.oab-apis-deployment-prod.bucket} --recursive"
  }
}

resource "aws_s3_bucket" "jazz_s3_api_doc" {
  bucket_prefix = "${var.envPrefix}-jazz-s3-api-doc-"
  request_payer = "BucketOwner"
  depends_on = ["aws_api_gateway_rest_api.jazz-prod" ]
  acl = "public-read"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags {
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
  }
  website {
    index_document = "index.html"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws s3 rm s3://${aws_s3_bucket.jazz_s3_api_doc.bucket} --recursive"
  }
}

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
    command = "${var.configureApikey_cmd} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-stg.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.region} ${var.jenkinsjsonpropsfile} ${var.jenkinsattribsfile} ${var.envPrefix}"
  }
}

resource "aws_s3_bucket" "jazz-web" {
  bucket_prefix = "${var.envPrefix}-web-"
  request_payer = "BucketOwner"
  depends_on = ["aws_s3_bucket.jazz_s3_api_doc" ]
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags {
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
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
    command = "${var.deployS3Webapp_cmd} ${aws_s3_bucket.jazz-web.bucket} ${var.region} ${data.aws_canonical_user_id.current.id}"
  }

  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws s3 rm s3://${aws_s3_bucket.jazz-web.bucket}/ --recursive"
  }
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

  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
  }

  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws iam detach-role-policy --role-name ${aws_iam_role.lambda_role.name} --policy-arn arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
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
resource "aws_s3_bucket" "dev-serverless-static" {
  bucket_prefix = "${var.envPrefix}-dev-web-"
  request_payer = "BucketOwner"

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags {
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws s3 rm s3://${aws_s3_bucket.dev-serverless-static.bucket} --recursive"
  }
}

resource "aws_s3_bucket" "stg-serverless-static" {
  bucket_prefix = "${var.envPrefix}-stg-web-"
  request_payer = "BucketOwner"

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags {
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
  }
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws s3 rm s3://${aws_s3_bucket.stg-serverless-static.bucket} --recursive"
  }

}

resource "aws_s3_bucket" "prod-serverless-static" {
  bucket_prefix = "${var.envPrefix}-prod-web-"
  request_payer = "BucketOwner"

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags {
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
  }

  # TODO do we need this, or does `force_destroy` suffice?
  provisioner "local-exec" {
    when = "destroy"
    on_failure = "continue"
    command = "aws s3 rm s3://${aws_s3_bucket.prod-serverless-static.bucket} --recursive"
  }

}

data "aws_iam_policy_document" "dev-serverless-static-policy-data-contents" {
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    actions = [
      "s3:*"
    ]
    principals  {
      type="AWS",
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }
    resources = [
      "${aws_s3_bucket.dev-serverless-static.arn}/*"
    ]

  }
  statement {
    actions = [
      "s3:ListBucket"
    ]
    principals  {
      type="AWS",
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }
    resources = [
      "${aws_s3_bucket.dev-serverless-static.arn}"
    ]

  }
}
resource "aws_s3_bucket_policy" "dev-serverless-static-bucket-contents-policy" {
  bucket = "${aws_s3_bucket.dev-serverless-static.id}"
  policy = "${data.aws_iam_policy_document.dev-serverless-static-policy-data-contents.json}"
}

data "aws_iam_policy_document" "stg-serverless-static-policy-data-contents" {
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    actions = [
      "s3:*"
    ]
    principals  {
      type="AWS",
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }
    resources = [
      "${aws_s3_bucket.stg-serverless-static.arn}/*"
    ]

  }
  statement {
    actions = [
      "s3:ListBucket"
    ]
    principals  {
      type="AWS",
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }
    resources = [
      "${aws_s3_bucket.stg-serverless-static.arn}"
    ]

  }
}

resource "aws_s3_bucket_policy" "stg-serverless-static-bucket-contents-policy" {
  bucket = "${aws_s3_bucket.stg-serverless-static.id}"
  policy = "${data.aws_iam_policy_document.stg-serverless-static-policy-data-contents.json}"
}

data "aws_iam_policy_document" "prod-serverless-static-policy-data-contents" {
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    sid = "1"
    actions = [
      "s3:*"
    ]
    principals  {
      type="AWS",
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }
    resources = [
      "${aws_s3_bucket.prod-serverless-static.arn}/*"
    ]
  }
  statement {
    sid = "ListBucket"
    actions = [
      "s3:ListBucket"
    ]
    principals  {
      type="AWS",
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }
    resources = [
      "${aws_s3_bucket.prod-serverless-static.arn}"
    ]
  }
}
resource "aws_s3_bucket_policy" "prod-serverless-static-bucket-contents-policy" {
  bucket = "${aws_s3_bucket.prod-serverless-static.id}"
  policy = "${data.aws_iam_policy_document.prod-serverless-static-policy-data-contents.json}"
}

data "aws_iam_policy_document" "jazz-web-policy-data-contents" {
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    sid = "1"
    actions = [
      "s3:*"
    ]
    principals  {
      type="AWS",
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }
    resources = [
      "${aws_s3_bucket.jazz-web.arn}/*"
    ]

  }
  statement {
    sid = "ListBucket"
    actions = [
      "s3:ListBucket"
    ]
    principals  {
      type="AWS",
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }
    resources = [
      "${aws_s3_bucket.jazz-web.arn}"
    ]

  }
  statement {
    sid = "jazzwebsite"
    actions = [
      "s3:GetObject"
    ]
    principals  {
      type="AWS",
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${ element(split( "/",  "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"), 2)}"]
    }
    resources = [
      "${aws_s3_bucket.jazz-web.arn}/*"
    ]

  }

}
resource "aws_s3_bucket_policy" "jazz-web-bucket-contents-policy" {
  depends_on = ["aws_cloudfront_distribution.jazz" ]
  bucket = "${aws_s3_bucket.jazz-web.id}"
  policy = "${data.aws_iam_policy_document.jazz-web-policy-data-contents.json}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "jazz_s3_api_doc_bucket_contents" {
  policy_id = "jazz-s3-api-doc-bucket-contents"
  statement {
    sid = "jazz-s3-api-doc-admin-access"
    actions = [
      "s3:*"
    ]
    principals  {
      type="AWS",
      identifiers = ["${data.aws_caller_identity.current.arn}"]
    }
    resources = [
      "${aws_s3_bucket.jazz_s3_api_doc.arn}/*"
    ]
  }
  statement {
    sid = "jazz-s3-api-doc-get-object"
    actions = [
      "s3:GetObject"
    ]
    principals  {
      type="*",
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.jazz_s3_api_doc.arn}/*"
    ]
  }
  statement {
    sid = "jazz-s3-api-doc-list-bucket"
    actions = [
      "s3:ListBucket"
    ]
    principals  {
      type="*",
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.jazz_s3_api_doc.arn}"
    ]
  }
}
resource "aws_s3_bucket_policy" "jazz-s3-api-doc-bucket-contents-policy" {
  bucket = "${aws_s3_bucket.jazz_s3_api_doc.id}"
  policy = "${data.aws_iam_policy_document.jazz_s3_api_doc_bucket_contents.json}"
}
