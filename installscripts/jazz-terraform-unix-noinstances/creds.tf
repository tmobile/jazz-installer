provider "aws" {
    #This ec2-user user is of Installer box
    shared_credentials_file  = "/home/centos/.aws/credentials"
    profile                  = "default"
    region = "${var.region}"
}
