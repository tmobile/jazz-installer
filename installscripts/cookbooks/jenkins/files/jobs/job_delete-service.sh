JENKINS_URL=http://$1:8080/ # localhost or jenkins elb url
JOB_NAME=$2
BITBUCKET_ELB=$3
AUTHFILE=/home/ec2-user/cookbooks/jenkins/files/default/authfile
JENKINS_CLI=/home/ec2-user/jenkins-cli.jar
JENKINS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "jenkins1"|cut -d" " -f1`
echo "$0 $1 $2 "
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-job $JOB_NAME
<flow-definition plugin="workflow-job@2.12">
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>service_name</name>
          <description></description>
          <defaultValue>newServissceX</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>domain</name>
          <description></description>
          <defaultValue>slf</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>version</name>
          <description></description>
          <defaultValue>1.0</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>tracking_id</name>
          <description></description>
          <defaultValue>1001</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>db_service_id</name>
          <description></description>
          <defaultValue></defaultValue>
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
          <url>http://$BITBUCKET_ELB:7990/scm/slf/delete-serverless-service-build-pack.git</url>
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
  <authToken>slf-0714-delserv</authToken>
  <disabled>false</disabled>
</flow-definition>
EOF
