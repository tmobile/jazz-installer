JENKINS_CLI_CMD=$1
SCM_ELB=$2

JENKINS_CREDENTIAL_ID=`$JENKINS_CLI_CMD list-credentials system::system::jenkins | grep "jenkins1"|cut -d" " -f1`
cat <<EOF | $JENKINS_CLI_CMD create-job "Gitlab-Trigger-Job"
<?xml version='1.0' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.12">
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
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
          <url>http://$SCM_ELB/slf/gitlab-build-pack.git</url>
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
