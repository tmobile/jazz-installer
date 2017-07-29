resource "aws_elasticsearch_domain" "elasticsearch_domain" {
	depends_on = ["null_resource.configureExistingJenkinsServer"]
	domain_name           = "${var.envPrefix}-elasticsearch-domain"
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

	tags { Domain = "${var.envPrefix}_elasticsearch_domain"  }
  provisioner "local-exec" {
    command = "${var.configureESEndpoint_cmd} ${aws_elasticsearch_domain.elasticsearch_domain.endpoint} ${lookup(var.jenkinsservermap, "jenkins_elb")} ${var.region}"
  }
}
resource "aws_elasticsearch_domain_policy" "elasticsearchdomain_policy" {
  domain_name = "${aws_elasticsearch_domain.elasticsearch_domain.domain_name}"

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
      	    "Principal": {
		"AWS": "*"
            	},
            "Effect": "Allow",
            "Resource": "${aws_elasticsearch_domain.elasticsearch_domain.arn}/*"
        }
    ]
}
POLICIES
}

