resource "null_resource" "configureExistingJenkinsServer" {

  depends_on = ["aws_api_gateway_rest_api.jazz-dev","aws_s3_bucket.jazz-web","aws_iam_role.lambda_role","aws_elasticsearch_domain.elasticsearch_domain","ses_setup" ]

  connection {
    host = "${lookup(var.jenkinsservermap, "jenkins_public_ip")}"
    user = "${lookup(var.jenkinsservermap, "jenkins_ssh_login")}"
    type = "ssh"
    private_key = "${file("${lookup(var.jenkinsservermap, "jenkins_ssh_key")}")}"
  }
  provisioner "local-exec" {
    command = "${var.configureJenkinselb_cmd} ${lookup(var.jenkinsservermap, "jenkins_elb")} ${var.jenkinsattribsfile} ${var.bitbucketclient_cmd}"
  }
  provisioner "local-exec" {
    command = "${var.configurebitbucketelb_cmd} ${lookup(var.bitbucketservermap, "bitbucket_elb")}  ${var.chefconfigDir}/bitbucketelbconfig.json ${var.jenkinsattribsfile} ${var.jenkinspropsfile} ${var.bitbucketclient_cmd} ${var.envPrefix}"
  }
   provisioner "file" {
          source      = "${var.cookbooksDir}"
          destination = "~/cookbooks"
  }
  provisioner "file" {
          source      = "${var.chefconfigDir}"
          destination = "~/chefconfig"
  }

 provisioner "remote-exec" {
    inline = [
          "sudo sh ~/cookbooks/installChef.sh",
                  "sudo cd /var/lib/jenkins/",
                  "sudo cat ~/cookbooks/jenkins/files/plugins/plugins0* >plugins.tar",
                  "sudo tar -xf plugins.tar -C /var/lib/jenkins/",
                  "sudo curl -O https://bootstrap.pypa.io/get-pip.py&& sudo python get-pip.py",
                  "sudo chmod -R o+w /usr/lib/python2.7/site-packages/ /usr/bin/",
                  "sudo cp ~/.bash_profile /var/lib/jenkins; sudo cp ~/.bashrc /var/lib/jenkins",
                  "sudo chef-client --local-mode -c ~/chefconfig/client.rb -j ~/chefconfig/node-jenkinsserver-packages.json"
    ]
  }
     provisioner "file" {
          source      = "${var.cookbooksDir}"
          destination = "~/cookbooks"
  }

  provisioner "file" {
          source      = "${var.cookbooksDir}/jenkins/recipes"
          destination = "~/cookbooks/jenkins"
  }
  provisioner "file" {
          source      = "${var.cookbooksDir}/jenkins/files/default"
          destination = "~/cookbooks/jenkins/files"
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
          destination = "~/cookbooks/jenkins"
  }
  provisioner "file" {
          source      = "${var.cookbooksDir}/jenkins/attributes/"
          destination = "~/cookbooks/blankJenkins/attributes/"
  }

  provisioner "file" {
          source      = "${var.chefconfigDir}/"
          destination = "~/chefconfig"
  }

 provisioner "remote-exec" {
    inline = [
          "sudo chef-client --local-mode -c ~/chefconfig/client.rb --override-runlist blankJenkins::configureblankjenkins"
    ]
  }

  provisioner "local-exec" {
    command = "${var.modifyCodebase_cmd}  ${lookup(var.jenkinsservermap, "security_group")} ${lookup(var.jenkinsservermap, "subnet")} ${aws_iam_role.lambda_role.arn} ${var.region} ${var.envPrefix}"
  }

}
resource "null_resource" "configureExistingBitbucketServer" {

  depends_on = ["null_resource.configureExistingJenkinsServer","aws_elasticsearch_domain.elasticsearch_domain"]

  connection {
    host = "${lookup(var.bitbucketservermap, "bitbucket_public_ip")}"
    user = "${lookup(var.bitbucketservermap, "bitbucket_ssh_login")}"
    type = "ssh"
    private_key = "${file("${lookup(var.bitbucketservermap, "bitbucket_ssh_key")}")}"
  }
  provisioner "file" {
          source      = "${var.chefconfigDir}/bitbucketelbconfig.json"
          destination = "~/chefconfig/bitbucketelbconfig.json"
  }
  provisioner "remote-exec" {
    inline = [
          "pwd"
    ]
  }
  provisioner "local-exec" {
    command = "${var.bitbucketclient_cmd} ${var.region}"
  }

}
