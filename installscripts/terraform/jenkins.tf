provider "aws" {
	shared_credentials_file  = "C:/Users/admin/.aws/credentials"
	profile                  = "default"
    region = "us-east-1"
}

resource "aws_s3_bucket" "jazz-api-deployment-dev" {
  bucket = "jazz1-api-deployment-dev"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "us-east-1"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  provisioner "local-exec" {
    command = "sets3acl.cmd ${aws_s3_bucket.jazz-api-deployment-dev.bucket}"
  }
}
resource "aws_s3_bucket" "oab-apis-deployment-dev" {
  bucket = "oab1-apis-deployment-dev"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "us-east-1"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  provisioner "local-exec" {
    command = "sets3acl.cmd ${aws_s3_bucket.oab-apis-deployment-dev.bucket}"
  }
  provisioner "local-exec" {
	when = "destroy"
    command = "	aws s3 rm s3://oab1-apis-deployment-dev --recursive"
  }

}
resource "aws_s3_bucket" "oab-apis-deployment-stg" {
  bucket = "oab1-apis-deployment-stg"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "us-east-1"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  provisioner "local-exec" {
    command = "sets3acl.cmd ${aws_s3_bucket.oab-apis-deployment-stg.bucket}"
  }
  provisioner "local-exec" {
	when = "destroy"
    command = "	aws s3 rm s3://oab1-apis-deployment-stg --recursive"
  }

}
resource "aws_s3_bucket" "oab-apis-deployment-prod" {
  bucket = "oab1-apis-deployment-prod"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "us-east-1"
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  
  provisioner "local-exec" {
    command = "sets3acl.cmd ${aws_s3_bucket.oab-apis-deployment-prod.bucket}"
  }
  provisioner "local-exec" {
	when = "destroy"
    command = "	aws s3 rm s3://oab1-apis-deployment-prod --recursive"
  }
  
}

resource "aws_api_gateway_rest_api" "jazz-dev" {
  name        = "jazz1-dev"
  description = "API for Tmobile demo1"
  provisioner "local-exec" {
    command = "git clone -b master https://github.com/tmobile/jazz.git jazz-core"

  }
  provisioner "local-exec" {
    command = "configureApikey.cmd ${aws_api_gateway_rest_api.jazz-dev.id} us-east-1 ${var.jenkinspropsfile}"
  }
  provisioner "local-exec" {
	when = "destroy"
    command = "	rm -rf ./jazz-core; rm -rf ./jazz-core-bitbucket"
  }
}
resource "aws_s3_bucket" "jazz-web" {
  bucket = "jazz1-web"
  acl    = "public-read-write"
  request_payer = "BucketOwner"
  region = "us-east-1"
  depends_on = ["aws_api_gateway_rest_api.jazz-dev" ]
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
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
    command = "aws s3 cp ./jazz-core/cloud-api-onboarding-website/app s3://${aws_s3_bucket.jazz-web.bucket} --recursive --region us-east-1"
  }
  provisioner "local-exec" {
    command = "sets3acl.cmd ${aws_s3_bucket.jazz-web.bucket}"
  }
  provisioner "local-exec" {
    command = "sets3aclrecurs.bat ${aws_s3_bucket.jazz-web.bucket} ./jazz-core/cloud-api-onboarding-website/app"
  }  
  provisioner "local-exec" {
	when = "destroy"
    command = "	aws s3 rm s3://jazz1-web --recursive"
  }
  provisioner "local-exec" {
	when = "destroy"
    command = "rm -rf ./jazz-core"
  }
  provisioner "local-exec" {
	when = "destroy"
    command = "rm -rf ./jazz-core-bitbucket"
  }
}



resource "aws_iam_policy" "basic_execution_policy" {
  name        = "basic1_execution_aws_logs"
  path        = "/"
  description = "aws_logs access policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda1_basic_execution_1"
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
    policy_arn = "${aws_iam_policy.basic_execution_policy.arn}"
}

//resource "aws_key_pair" "auth" {
 // key_name   = "${lookup(var.keypair, "key_name")}"
  //public_key = "${file("${lookup(var.keypair, "public_key")}")}"
//}
# Create a VPC to launch our instances into
resource "aws_vpc" "demo1" {
  cidr_block = "10.0.0.0/16"
  tags {  Name = "demo1VPC"  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "demo1" {
  vpc_id = "${aws_vpc.demo1.id}"
  tags {  Name = "demo1Gateway"  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.demo1.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.demo1.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "demo1" {
  vpc_id                  = "${aws_vpc.demo1.id}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags {  Name = "demo1subnet"  }
  
}
# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "jenkinselb_demo1" {
  name        = "jenkinselb_demo1_sg"
  description = "Used for jenkins elb"
  vpc_id      = "${aws_vpc.demo1.id}"
  tags {  Name = "demo1_jenkinselb"  }

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "bitbucketelb_demo1" {
  name        = "bitbucketelb__demo1_sg"
  description = "Used for bitbucketelb demo1"
  vpc_id      = "${aws_vpc.demo1.id}"
  tags {  Name = "demo1_bitbucketelb"  }

  
  # Bitbucket ports
  ingress {
    from_port   = 7990
    to_port     = 7990
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 7992
    to_port     = 7992
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 7993
    to_port     = 7993
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "jenkins" {
  name        = "jenkins_sg"
  description = "Used for jenkins server"
  vpc_id      = "${aws_vpc.demo1.id}"
  tags {  Name = "demo1_jenkins_server"}

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bitbucket" {
  name        = "bitbucketserver_sg"
  description = "Used for bitbuckerserver"
  vpc_id      = "${aws_vpc.demo1.id}"
  tags {  Name = "demo1_bitbucket_server" }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7990
    to_port     = 7990
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 7992
    to_port     = 7992
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 7993
    to_port     = 7993
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "jenkinsserver" {
  instance_type = "t2.medium"
  ami = "${var.jenkinsserver_ami}"
  key_name   = "${lookup(var.keypair, "key_name")}"
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]
  subnet_id = "${aws_subnet.demo1.id}"
  depends_on = ["aws_elb.jenkinselb","aws_elb.bitbucketelb","aws_api_gateway_rest_api.jazz-dev","aws_s3_bucket.jazz-api-deployment-dev","aws_s3_bucket.jazz-web","aws_iam_role.lambda_role" ]
//  depends_on = ["aws_elb.jenkinselb","aws_elb.bitbucketelb" ]
  tags {  Name = "Demo1_jenkinsserver"  }
  connection {
    user = "ec2-user"
	type     = "ssh"
	private_key = "${file("${lookup(var.keypair, "private_key")}")}"
  }   
  provisioner "local-exec" {
    command = "modifyJenkinsServerIp.cmd ${aws_instance.jenkinsserver.private_ip}  ${var.jenkinsattribsfile}"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/recipes/startjenkins.rb"
	  destination = "~/cookbooks/jenkins/recipes/startjenkins.rb"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/files/default"
	  destination = "~/cookbooks/jenkins/files/"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/files/jobs"
	  destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/files/node"
	  destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/files/scriptapproval"
	  destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/files/credentials"
	  destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/attributes"
	  destination = "~/cookbooks/jenkins/"
  }
  provisioner "remote-exec" {
    inline = [
	  "sudo chef-client --local-mode -c ~/chefconfig/client.rb --override-runlist jenkins::startjenkins"
    ]
  }
  
  provisioner "local-exec" {
    command = "modifyCodebase.cmd  ${aws_security_group.jenkins.id} ${aws_subnet.demo1.id} ${aws_iam_role.lambda_role.arn} us-east-1"
  }
#  provisioner "local-exec" {
#    command = "bash -c cat <<EOF | java -jar ../lib/jenkins-cli.jar -s http://${aws_elb.jenkins-elb.dns_name}:8080 -auth @../lib/authfile update-node jenkinslave2 ${file("./jenkinslave2.xml")} EOF"
#    command = "bash -c "./configureSlave.sh ${aws_elb.jenkins-elb.dns_name} jenkinsslave1 ${aws_instance.jenkinsslave.public_ip}""
#  }
}
/*
resource "aws_instance" "jenkinsslave" {

  instance_type = "t2.micro"
  ami = "${var.jenkinsslave_ami}"
  key_name   = "${lookup(var.keypair, "key_name")}"
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]
  subnet_id = "${aws_subnet.demo1.id}"
  depends_on = ["aws_instance.jenkinsserver","aws_elb.jenkinselb","aws_elb_attachment.jenkins"]
  
  tags {  Name = "Demo1_jenkinsslave"  }
  connection {
    user = "ec2-user"
	type     = "ssh"
	private_key = "${file("${lookup(var.keypair, "private_key")}")}"
  } 
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/files/default"
	  destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/files/node"
	  destination = "~/cookbooks/jenkins/files"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/recipes"
	  destination = "~/cookbooks/jenkins"
  }
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins/attributes"
	  destination = "~/cookbooks/jenkins"
  }

  provisioner "remote-exec" {
    inline = [
	  "sudo chef-client --local-mode -c ~/chefconfig/client.rb --override-runlist jenkins::slave"
    ]
  }
}
*/
resource "aws_instance" "bitbucketserver" {
  instance_type = "t2.medium"
  ami = "${var.bitbucketserver_ami}"
  key_name   = "${lookup(var.keypair, "key_name")}"
  vpc_security_group_ids = ["${aws_security_group.bitbucket.id}"]
  subnet_id = "${aws_subnet.demo1.id}"
  depends_on = ["aws_elb.bitbucketelb"]
  tags {  Name = "Demo1_bitbucketserver"  }
  connection {
    user = "ec2-user"
	type     = "ssh"
	private_key = "${file("${lookup(var.keypair, "private_key")}")}"
  } 
  provisioner "file" {
	  source      = "${var.chefconfigDir}/bitbucketelbconfig.json"
	  destination = "~/chefconfig/bitbucketelbconfig.json"
  }
  provisioner "remote-exec" {
    inline = [
	  "sudo chef-client --local-mode -c ~/chefconfig/client.rb -j ~/chefconfig/bitbucketelbconfig.json --override-runlist bitbucket::startserver"
    ]
  }
}
resource "aws_elb" "jenkinselb" {
  name = "demo1jenkinselb"
  subnets         = ["${aws_subnet.demo1.id}"]
  security_groups = ["${aws_security_group.jenkinselb_demo1.id}"]
  tags {  Name = "Demo1_jenkinsserver_elb"  }
  depends_on = ["aws_api_gateway_rest_api.jazz-dev","aws_s3_bucket.jazz-api-deployment-dev","aws_s3_bucket.jazz-web" ]
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:8080"
    interval            = 30
  }  
  provisioner "local-exec" {
    command = "configureJenkinselb.cmd ${aws_elb.jenkinselb.dns_name} ${var.jenkinsattribsfile}"
  }  
}
resource "aws_elb" "bitbucketelb" {
  name = "demo1bitbucketelb"
  subnets         = ["${aws_subnet.demo1.id}"]
  security_groups = ["${aws_security_group.bitbucketelb_demo1.id}"]
  tags {  Name = "Demo1_bitbucketserver_elb"  }
  depends_on = ["aws_api_gateway_rest_api.jazz-dev","aws_s3_bucket.jazz-api-deployment-dev","aws_s3_bucket.jazz-web" ]

  listener {
    instance_port     = 7990
    instance_protocol = "http"
    lb_port           = 7990
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 7992
    instance_protocol = "http"
    lb_port           = 7992
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 7993
    instance_protocol = "http"
    lb_port           = 7993
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:7990"
    interval            = 30
  }
  provisioner "local-exec" {
    command = "configurebitbucketelb.cmd ${aws_elb.bitbucketelb.dns_name}  ${var.chefconfigDir}/bitbucketelbconfig.json ${var.jenkinsattribsfile} ${var.jenkinspropsfile} "
  }   
}

resource "aws_elb_attachment" "jenkins" {
  elb      = "${aws_elb.jenkinselb.id}"
  instance = "${aws_instance.jenkinsserver.id}"
//  provisioner "local-exec" {
//    command = "C:/project/software/curl-7.33.0/curl  http://${aws_elb.jenkinselb.dns_name}:8080/job/inst_deploy_createservice/build?token=triggerCreateService --user jenkinsadmin:jenkinsadmin"
//  }
}

resource "aws_elb_attachment" "bitbucket" {
  elb      = "${aws_elb.bitbucketelb.id}"
  instance = "${aws_instance.bitbucketserver.id}"
  depends_on = ["aws_elb_attachment.jenkins"]
//  provisioner "local-exec" {
  //  command = "bitbucketclient.cmd ${aws_elb.jenkinselb.dns_name} ${aws_elb.bitbucketelb.dns_name}"
  //}  

}
