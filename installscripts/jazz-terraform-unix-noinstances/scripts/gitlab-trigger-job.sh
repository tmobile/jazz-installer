JENKINS_URL=http://$1/ # localhost or jenkins elb url
JOB_NAME="Gitlab-Trigger-Job"
USERNAME=
PASSWORD=

JENKINS_CLI=./jenkins-cli.jar

cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth $USERNAME:$PASSWORD create-job $JOB_NAME
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
          <secretToken>replace</secretToken>
        </com.dabsquared.gitlabjenkins.GitLabPushTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.36">
   <script>#!groovy.

node  {
//echo sh(returnStdout: true, script: &apos;env&apos;)

def gitlab_credentialsId   = env.REPO_CREDENTIAL_ID
def gitlab_repo_base       = env.REPO_BASE
def gitlab_repo_url        = &quot;http://&quot; + gitlab_repo_base + &quot;/&quot; + env.REPO_LOC + &quot;/&quot;

def jenkins_username  = env.JENKINS_USERNAME
def jenkins_password  = env.JENKINS_PASSWORD

def gitlab_repo_name  = env.gitlabSourceRepoName
def gitlab_branch     = env.gitlabBranch
def service_type = &apos;&apos;
def service_name = &apos;&apos;
def domain_name  = &apos;&apos;

echo &quot;gitlab_credentialsId:gitlab_credentialsId&quot;
echo &quot;gitlab_repo_url:$gitlab_repo_url&quot;
echo &quot;gitlab_repo_name:$gitlab_repo_name&quot;
echo &quot;gitlab_branch:$gitlab_branch&quot;

try{
       sh &apos;rm -rf $gitlab_repo_name*&apos;
       dir(gitlab_repo_name)
       {
               checkout([$class: &apos;GitSCM&apos;, branches: [[name: &apos;*/master&apos;]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: gitlab_credentialsId, url: gitlab_repo_url + gitlab_repo_name + &apos;.git&apos;]]])

          //Find the service type
          if (fileExists(&apos;build.api&apos;)) {
                               service_type = &quot;api&quot;
          } else if(fileExists(&apos;build.lambda&apos;)) {
                               service_type = &quot;lambda&quot;
          } else if(fileExists(&apos;build.website&apos;)) {
                               service_type = &quot;website&quot;
          }

          //Read the JenkinsFile to find the service name and domain
           def jenkinsfile_dir = sh (
                      script: &quot;pwd&quot; ,
                      returnStdout: true
              ).trim()
          myFileName = jenkinsfile_dir + &quot;/Jenkinsfile&quot;

          //Read the Jenkins File
          def curl_cmd = &apos;&apos;
          if(fileExists(myFileName)) {
              def result = readFile(myFileName).trim()
              def resultList = result.tokenize(&quot;\n&quot;)
              for (i in resultList) {
                      if(i.trim().toLowerCase().startsWith(&quot;sh \&quot;curl&quot;)) {
                          curl_cmd = i.trim().substring(3)
                      }
              }//for

              echo &quot;curl:$curl_cmd&quot;
              def cmd_split = curl_cmd.split(&apos;&amp;&apos;)
              for (s in cmd_split) {
                      if(s.trim().toLowerCase().startsWith(&quot;service_name&quot;)) {
                          service_name=s.split(&apos;=&apos;)[1]
                      } else if(s.trim().toLowerCase().startsWith(&quot;domain&quot;)) {
                          domain_name=s.split(&apos;=&apos;)[1]
                      }
              }//for
          }//if
      }

      sh &apos;rm -rf $gitlab_repo_name*&apos;
  }
  catch(error){
      //do nothing
      echo &quot;Error Occured..&quot;
  }

  //Get the Build URL
  if (service_type == &apos;api&apos;){
      build_job = env.API_BUILD_URI_DEV
      if ( gitlab_branch == &apos;master&apos;) {
          build_job = env.API_BUILD_URI
      }
  }else if(service_type == &apos;website&apos;) {
      build_job = env.WEBSITE_BUILD_URI_DEV
      if ( gitlab_branch == &apos;master&apos;) {
          build_job = env.WEBSITE_BUILD_URI
      }

      //Add scm_project as cas
      build_job = build_job + &quot;&amp;scm_project=cas&quot;
   } else if (service_type == &apos;lambda&apos; || service_type == &apos;function&apos;){
      build_job = env.LAMBDA_BUILD_URI_DEV
      if ( gitlab_branch == &apos;master&apos;) {
          build_job = env.LAMBDA_BUILD_URI
      }
  }

  echo &quot;service_type:$service_type&quot;
  echo &quot;build_job:$build_job&quot;
  echo &quot;domain_name:$domain_name&quot;
  echo &quot;service_name:$service_name&quot;

  def job_url = JenkinsLocationConfiguration.get().getUrl() + build_job
  echo &quot;job_url:$job_url&quot;

  if ( service_type != &apos;&apos; &amp;&amp; service_name != &apos;&apos; &amp;&amp; domain_name != &apos;&apos;) {
      echo &quot;Call the build job&quot;
      sh &quot;curl -X GET -k -v -u \&quot;$jenkins_username:$jenkins_password\&quot;  \&quot;&quot; + job_url + &quot;&amp;service_name=$service_name&amp;domain=$domain_name&amp;scm_branch=$gitlab_branch\&quot;&quot;
   }
   else
   {
      echo &quot;Error:ServiceType or ServiceName or DomainName is empty&quot;
   }
}</script>
  <sandbox>true</sandbox>
</definition>
<triggers/>
<disabled>false</disabled>
</flow-definition>
