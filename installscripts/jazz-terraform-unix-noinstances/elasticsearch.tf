resource "aws_elasticsearch_domain" "elasticsearch_domain" {
  domain_name           = "${var.envPrefix}"
  elasticsearch_version = "5.1"
  cluster_config {
    instance_type = "m3.medium.elasticsearch"
    instance_count =2
    dedicated_master_enabled = false
    zone_awareness_enabled= false
  }
  ebs_options{
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 10
  }

  tags {
    Domain = "${var.envPrefix}_elasticsearch_domain"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
  }
  //vpc_options {
  //  security_group_ids = ["${lookup(var.jenkinsservermap, "jenkins_security_group")}"],
  //  subnet_ids = ["${lookup(var.jenkinsservermap, "jenkins_subnet")}"]
  //}
  access_policies = <<POLICIES

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": {
                "AWS": "*"
                },
            "Effect": "Allow"
        }
    ]
}
POLICIES

}

resource "null_resource" "updateSecurityGroup" {
   provisioner "local-exec" {
    command    = "aws ec2 authorize-security-group-ingress --group-id ${lookup(var.jenkinsservermap, "jenkins_security_group")} --protocol tcp --port 443 --source-group ${lookup(var.jenkinsservermap, "jenkins_security_group")} --region ${var.region}"
    on_failure = "continue"
  }
}
