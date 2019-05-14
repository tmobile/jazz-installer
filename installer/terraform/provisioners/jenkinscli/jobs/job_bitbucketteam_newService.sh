#!/bin/sh

JENKINS_CLI_CMD=$1
BITBUCKET_ELB=$2

JENKINS_CREDENTIAL_ID=$($JENKINS_CLI_CMD list-credentials system::system::jenkins | grep "jazz_repocreds"|cut -d" " -f1)
cat <<EOF | $JENKINS_CLI_CMD create-job "Jazz_User_Services"
<jenkins.branch.OrganizationFolder plugin="branch-api@2.0.10">
  <actions/>
  <description></description>
  <displayName>Jazz_User_Services</displayName>
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
      <repoOwner>CAS</repoOwner>
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
