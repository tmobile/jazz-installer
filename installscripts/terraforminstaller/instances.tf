# Our installer security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "installer" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${var.vpc}"
  tags {  Name = "${var.envPrefix}"  }

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

resource "aws_key_pair" "auth" {
  key_name   = "${lookup(var.keypair, "key_name")}-${var.envPrefix}"
  public_key = "${file("${lookup(var.keypair, "public_key")}")}"
}

resource "aws_instance" "installer" {

  instance_type = "t2.large"
  ami = "${var.installer_ami}"
  key_name   = "${aws_key_pair.auth.key_name}"
  vpc_security_group_ids = ["${aws_security_group.installer.id}"]
  subnet_id = "${var.subnet}"
  tags {  Name = "${var.envPrefix}"  }
    Application = "${var.tagsApplication}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
  root_block_device {
	volume_type = "gp2"
	volume_size = 20
  }

  connection 
  {
    user = "ec2-user"
	type     = "ssh"
	private_key = "${file("${lookup(var.keypair, "private_key")}")}"
  }   

  provisioner "file" {
          source      = "./startup.sh"
          destination = "~/starup.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo curl -L https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip?_ga=2.191030627.850923432.1499789921-755991382.1496973261 -o /tmp/terraform.zip",
      "sudo curl -L https://releases.hashicorp.com/packer/1.0.2/packer_1.0.2_linux_amd64.zip?_ga=2.211418261.1015376711.1499791279-168406014.1496924698 -o /tmp/packer.zip",
      "sudo curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/local/bin/jq; sudo chmod 755 /usr/local/bin/jq",
      "cd /usr/bin; sudo unzip /tmp/terraform.zip; sudo unzip /tmp/packer.zip",
      "sudo rm -f /etc/profile.d/aws.sh",
      "sudo chmod 755 ~/starup.sh; echo . ./starup.sh >> ~/.bash_profile",
      "cd /home/ec2-user; sudo curl -L https://bobswift.atlassian.net/wiki/download/attachments/16285777/atlassian-cli-6.7.1-distribution.zip -o /tmp/atlassian-cli-6.7.1-distribution.zip; sudo unzip /tmp/atlassian-cli-6.7.1-distribution.zip"

    ]
  }
}
