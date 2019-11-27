# These variables are set by user input
region = "This is set from the terraform CLI"
github_branch = "REPLACEME"
aws_access_key = "This is set from the terraform CLI"
aws_secret_key = "This is set from the terraform CLI"
jazz_accountid = "REPLACEME"
cognito_pool_username = "REPLACEME"
cognito_pool_password = "REPLACEME"
envPrefix = "replaceme"
tagsExempt = "REPLACEME"

#Jenkins server map (set programmatically by wizard, not directly by user or terraform)
jenkinsservermap = {
  jenkins_elb = "REPLACEME"
  jenkins_rawendpoint = "REPLACEME"
  jenkinsuser = "REPLACEME"
  jenkinspasswd = "REPLACEME"
  jenkins_ssh_login = "REPLACEME"
  jenkins_ssh_port = "22"
  jenkins_ssh_key = "REPLACEME"
  jenkins_security_group = "REPLACEME"
  jenkins_subnet = "REPLACEME"
}

#SCM server map (set programmatically by wizard, not directly by user or terraform)
scmmap = {
  scm_elb = "REPLACEME"
  scm_type = "REPLACEME"
  scm_publicip = "REPLACEME"
  scm_username = "REPLACEME"
  scm_passwd = "REPLACEME"
  scm_privatetoken = "REPLACEME"
  scm_slfid = "REPLACEME"
  scm_pathext = "REPLACEME"
}

#CodeQuality server map (set programmatically by wizard, not directly by user or terraform)
codeqmap = {
  sonar_server_elb = "REPLACEME"
  sonar_username = "REPLACEME"
  sonar_passwd = "REPLACEME"
}

scmbb = true
scmgitlab = false
codeq = false
dockerizedJenkins = true
additional_tags = {}
aws_tags = "[]"
network_range = "0.0.0.0/0"
dockerizedSonarqube = false
autovpc = false
vpc_cidr_block = "10.0.0.0/16"
existing_vpc_ecs = "replaceme"
acl_db_password = "REPLACEME"
