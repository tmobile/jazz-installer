provider "aws" {
    #This ec2-user user is of Installer box
    shared_credentials_file  = "/home/ec2-user/.aws/credentials"
    profile                  = "default"
    region = "${var.region}"
}


