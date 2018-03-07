/*
   Terraform looks for aws_credentials in the default location $HOME/.aws/credentials on Linux.
   If it fails to detect credentials inline, or in the environment, Terraform will check a custom location specified at shared_credentials_file.
   shared_credentials_file = "/path/to/cred/file"
*/
provider "aws" {
    profile = "default"
    region = "${var.region}"
}
