JENKINS_URL=http://$1/ # localhost or jenkins elb url
JENKINS_CLI=$2
AUTHFILE=$3
SCM_ELB=$4

echo "$0 $1 $2 $3 $4"

JOB_NAME="jazz_ui"

JENKINS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "jenkins1"|cut -d" " -f1`
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-job $JOB_NAME
<?xml version='1.0' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.12">
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.DisableConcurrentBuildsJobProperty/>
    <com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty plugin="gitlab-plugin@1.5.2">
      <gitLabConnection>Jazz-Gitlab</gitLabConnection>
    </com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
    <triggers>
      <com.dabsquared.gitlabjenkins.GitLabPushTrigger plugin="gitlab-plugin@1.5.2">
        <spec></spec>
        <triggerOnPush>true</triggerOnPush>
        <triggerOnMergeRequest>true</triggerOnMergeRequest>
        <triggerOnPipelineEvent>false</triggerOnPipelineEvent>
        <triggerOnAcceptedMergeRequest>false</triggerOnAcceptedMergeRequest>
        <triggerOnClosedMergeRequest>false</triggerOnClosedMergeRequest>
        <triggerOpenMergeRequestOnPush>never</triggerOpenMergeRequestOnPush>
        <triggerOnNoteRequest>true</triggerOnNoteRequest>
        <noteRegex>Jenkins please retry a build</noteRegex>
        <ciSkip>true</ciSkip>
        <skipWorkInProgressMergeRequest>true</skipWorkInProgressMergeRequest>
        <setBuildDescription>true</setBuildDescription>
        <branchFilterType>All</branchFilterType>
        <includeBranchesSpec></includeBranchesSpec>
        <excludeBranchesSpec></excludeBranchesSpec>
        <targetBranchRegex></targetBranchRegex>
        <secretToken></secretToken>
      </com.dabsquared.gitlabjenkins.GitLabPushTrigger>
    </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.36">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@3.3.0">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>http://$SCM_ELB/slf/jazz-ui.git</url>
          <credentialsId>jenkins1cred</credentialsId>
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
    <scriptPath>Jenkinsfile_Platform</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF
