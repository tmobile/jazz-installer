region = "REPLACEME"
github_branch = "REPLACEME"
aws_access_key = "REPLACEME"
aws_secret_key = "REPLACEME"
jazz_accountid = "REPLACEME"
cognito_pool_username = "REPLACEME"
cognito_pool_password = "REPLACEME"
envPrefix = "REPLACEME"
tagsEnvironment = "REPLACEME"
tagsExempt = "REPLACEME"
tagsOwner = "REPLACEME"

#Jenkins server map (set programmatically by wizard, not directly by user or terraform)
jenkinsservermap = {
  jenkins_elb = "REPLACEME"
  jenkinsuser = "REPLACEME"
  jenkinspasswd = "REPLACEME"
  jenkins_public_ip = "REPLACEME"
  jenkins_ssh_login = "REPLACEME"
  jenkins_ssh_port = "REPLACEME"
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
