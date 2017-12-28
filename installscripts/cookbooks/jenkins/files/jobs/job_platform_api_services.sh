JENKINS_URL=http://$1/ #localhost or jenkins elb url
JOB_NAME=$2 #Platform_API_Services
BITBUCKET_ELB=$3 
SSH_USER=$4

AUTHFILE=/home/$SSH_USER/cookbooks/jenkins/files/default/authfile
JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar

JENKINS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "jenkins1"|cut -d" " -f1`
echo "$0 $1 $2 "
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-job $JOB_NAME 
<jenkins.branch.OrganizationFolder plugin="branch-api@2.0.10">
  <actions/>
  <description></description>
  <displayName>$JOB_NAME</displayName>
  <properties>
    <org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig plugin="pipeline-model-definition@1.1.6">
      <dockerLabel></dockerLabel>
      <registry plugin="docker-commons@1.7"/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig>
    <jenkins.branch.NoTriggerOrganizationFolderProperty>
      <branches>.*</branches>
    </jenkins.branch.NoTriggerOrganizationFolderProperty>
  </properties>
  <folderViews class="jenkins.branch.OrganizationFolderViewHolder">
    <owner reference="../.."/>
  </folderViews>
  <healthMetrics>
    <com.cloudbees.hudson.plugins.folder.health.WorstChildHealthMetric plugin="cloudbees-folder@6.0.4">
      <nonRecursive>false</nonRecursive>
    </com.cloudbees.hudson.plugins.folder.health.WorstChildHealthMetric>
  </healthMetrics>
  <icon class="jenkins.branch.MetadataActionFolderIcon">
    <owner class="jenkins.branch.OrganizationFolder" reference="../.."/>
  </icon>
  <orphanedItemStrategy class="com.cloudbees.hudson.plugins.folder.computed.DefaultOrphanedItemStrategy" plugin="cloudbees-folder@6.0.4">
    <pruneDeadBranches>true</pruneDeadBranches>
    <daysToKeep>0</daysToKeep>
    <numToKeep>0</numToKeep>
  </orphanedItemStrategy>
  <triggers>
    <com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger plugin="cloudbees-folder@6.0.4">
      <spec>* * * * *</spec>
      <interval>60000</interval>
    </com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger>
  </triggers>
  <navigators>
    <com.cloudbees.jenkins.plugins.bitbucket.BitbucketSCMNavigator plugin="cloudbees-bitbucket-branch-source@2.1.2">
      <repoOwner>SLF</repoOwner>
      <credentialsId>$JENKINS_CREDENTIAL_ID</credentialsId>
      <checkoutCredentialsId>SAME</checkoutCredentialsId>
      <pattern>.*</pattern>
      <autoRegisterHooks>true</autoRegisterHooks>
      <bitbucketServerUrl>http://$BITBUCKET_ELB</bitbucketServerUrl>
      <sshPort>22</sshPort>
      <includes>*</includes>
      <excludes></excludes>
    </com.cloudbees.jenkins.plugins.bitbucket.BitbucketSCMNavigator>
  </navigators>
  <projectFactories>
    <org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProjectFactory plugin="workflow-multibranch@2.15">
      <scriptPath>Jenkinsfile</scriptPath>
    </org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProjectFactory>
  </projectFactories>
</jenkins.branch.OrganizationFolder>
EOF