# Specify the provider and access details
provider "aws" {
shared_credentials_file  = "/home/ec2-user/.aws/credentials"
profile                  = "default"
    region = "${var.region}"
}
