resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id   = "${lookup(var.lambdaCloudWatchProps, "statement_id")}"
  action         = "${lookup(var.lambdaCloudWatchProps, "action")}"
  function_name  = "${lookup(var.lambdaCloudWatchProps, "function_name")}"
  principal      = "${lookup(var.lambdaCloudWatchProps, "principal")}"
}

