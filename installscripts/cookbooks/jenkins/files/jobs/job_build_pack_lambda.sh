JENKINS_CLI_CMD=$1
BITBUCKET_ELB=$2

JENKINS_CREDENTIAL_ID=`$JENKINS_CLI_CMD list-credentials system::system::jenkins | grep "jazz_repocreds"|cut -d" " -f1`
cat <<EOF | $JENKINS_CLI_CMD create-job "build-pack-lambda"
<flow-definition plugin="workflow-job@2.12">
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
	<org.jenkinsci.plugins.workflow.job.properties.DisableConcurrentBuildsJobProperty/>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>service_name</name>
          <description></description>
          <defaultValue>JazzJS1</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>domain</name>
          <description></description>
          <defaultValue>slf</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>scm_branch</name>
          <description></description>
          <defaultValue>master</defaultValue>
        </hudson.model.StringParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers/>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.36">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@3.3.0">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>http://$BITBUCKET_ELB/slf/jenkins-build-pack-lambda.git</url>
          <credentialsId>$JENKINS_CREDENTIAL_ID</credentialsId>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/master</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <authToken>jazz-101-job</authToken>
  <disabled>false</disabled>
</flow-definition>

EOF
