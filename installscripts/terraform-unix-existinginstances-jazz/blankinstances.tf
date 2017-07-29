
resource "aws_key_pair" "auth" {
  key_name   = "${lookup(var.keypair, "key_name")}-${var.envPrefix}"
  public_key = "${file("${lookup(var.keypair, "public_key")}")}"
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "jenkinselb" {
  name        = "${var.envPrefix}_jenkinselb_sg"
  description = "Used for jenkins elb"
  vpc_id      = "${var.vpc}"
  tags {  Name = "${var.envPrefix}_jenkinselb"  }

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
resource "aws_security_group" "bitbucketelb" {
  name        = "${var.envPrefix}_bitbucketelb_sg"
  description = "Used for bitbucketelb demo"
  vpc_id      = "${var.vpc}"
  tags {  Name = "${var.envPrefix}_bitbucketelb"  }

  
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
  name        = "${var.envPrefix}_jenkins_sg"
  description = "Used for jenkins server"
  vpc_id      = "${var.vpc}"
  tags {  Name = "${var.envPrefix}_jenkins_server"}

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
    cidr_blocks = ["${var.cidrblocks}"]
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
  name        = "${var.envPrefix}_bitbucketserver_sg"
  description = "Used for bitbuckerserver"
  vpc_id      = "${var.vpc}"
  tags {  Name = "${var.envPrefix}_bitbucket_server" }

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
    cidr_blocks = ["${var.cidrblocks}"]
  }
  ingress {
    from_port   = 7992
    to_port     = 7992
    protocol    = "tcp"
    cidr_blocks = ["${var.cidrblocks}"]
  }
  ingress {
    from_port   = 7993
    to_port     = 7993
    protocol    = "tcp"
    cidr_blocks = ["${var.cidrblocks}"]
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
  key_name   = "${aws_key_pair.auth.key_name}"
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]
  subnet_id = "${var.subnet}"
  depends_on = ["aws_elb.jenkinselb","aws_elb.bitbucketelb" ]
  tags {  Name = "${var.envPrefix}_jenkinsserver"  }
    Application = "${var.tagsApplication}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  
}
resource "aws_instance" "bitbucketserver" {
  instance_type = "t2.medium"
  ami = "${var.bitbucketserver_ami}"
  key_name   = "${aws_key_pair.auth.key_name}"
  vpc_security_group_ids = ["${aws_security_group.bitbucket.id}"]
  subnet_id = "${var.subnet}"
  depends_on = ["aws_elb.bitbucketelb"]
  tags {  Name = "${var.envPrefix}_bitbucketserver"  }
    Application = "${var.tagsApplication}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
}
resource "aws_elb" "jenkinselb" {
  name = "${var.envPrefix}-jenkinselb"
  subnets         = ["${var.subnet}"]
  security_groups = ["${aws_security_group.jenkinselb.id}"]
  tags {  Name = "${var.envPrefix}_jenkinsserver_elb"  }
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
}
resource "aws_elb" "bitbucketelb" {
  name = "${var.envPrefix}-bitbucketelb"
  subnets         = ["${var.subnet}"]
  security_groups = ["${aws_security_group.bitbucketelb.id}"]
  tags {  Name = "${var.envPrefix}_bitbucketserver_elb"  }

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
}

resource "aws_elb_attachment" "jenkins" {
  elb      = "${aws_elb.jenkinselb.id}"
  instance = "${aws_instance.jenkinsserver.id}"
}

resource "aws_elb_attachment" "bitbucket" {
  elb      = "${aws_elb.bitbucketelb.id}"
  instance = "${aws_instance.bitbucketserver.id}"
  depends_on = ["aws_elb_attachment.jenkins"]


}
resource "null_resource" "provisionBlankJenkins" {
  depends_on = ["null_resource.outputVariables" ]
  connection {
	host = "${aws_instance.jenkinsserver.public_ip}"
	user = "ec2-user"
	type = "ssh"
	private_key = "${file("${lookup(var.keypair, "private_key")}")}"
  } 
  provisioner "file" {
	  source      = "${var.cookbooksDir}/jenkins"
	  destination = "~/cookbooks"
  }
  provisioner "remote-exec" {
    inline = [
	  "sudo chef-client --local-mode -c ~/chefconfig/client.rb --override-runlist jenkins::blankjenkins"
    ]
  }
}
resource "null_resource" "provisionBlankBitBucket" {
  depends_on = ["null_resource.outputVariables" ]
  connection {
	host = "${aws_instance.bitbucketserver.public_ip}"
	user = "ec2-user"
	type = "ssh"
	private_key = "${file("${lookup(var.keypair, "private_key")}")}"
  } 
  provisioner "local-exec" {
    command = "${var.configurebitbucketelb_cmd} ${aws_elb.bitbucketelb.dns_name}  ${var.chefconfigDir}/bitbucketelbconfig.json ${var.jenkinsattribsfile} ${var.jenkinspropsfile} ${var.bitbucketclient_cmd} ${var.envPrefix}"
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
