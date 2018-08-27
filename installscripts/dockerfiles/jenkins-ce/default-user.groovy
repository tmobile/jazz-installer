def env = System.getenv()
jenkins.model.Jenkins.instance.securityRealm.createAccount(env.JENKINS_USER, env.JENKINS_PASS)
