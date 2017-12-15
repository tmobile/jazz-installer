export JENKINS_URL=http://$1/ # localhost or jenkins elb url
export HOST_NAME=`hostname -i | cut -d" " -f2` 
export NODE_NAME=$2
export NODE_SLAVE_HOME="/home/ec2-user/$NODE_NAME"
export EXECUTORS=1
export SSH_PORT=22
export propsFilePath=/tmp/jenkins-conf.properties
export AUTHFILE=/home/ec2-user/cookbooks/jenkins/files/default/authfile
export JENKINS_CLI=/home/ec2-user/jenkins-cli.jar
#CRED_ID=$3 #9219e826-5f37-43df-b10b-51b2f4332a64
export CRED_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "ec2-user"|cut -d" " -f1`
echo $CRED_ID $JENKINS_URL $NODE_NAME
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-node $NODE_NAME
<slave>
  <name>${NODE_NAME}</name>
  <description></description>
  <remoteFS>${NODE_SLAVE_HOME}</remoteFS>
  <numExecutors>${EXECUTORS}</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.20">
    <host>${HOST_NAME}</host>
    <port>${SSH_PORT}</port>
    <credentialsId>${CRED_ID}</credentialsId>
    <maxNumRetries>0</maxNumRetries>
    <retryWaitTime>0</retryWaitTime>
    <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy"/>
  </launcher>
  <label></label>
  <nodeProperties>
    <hudson.slaves.EnvironmentVariablesNodeProperty>
      <envVars serialization="custom">
        <unserializable-parents/>
        <tree-map>
          <default>
            <comparator class="hudson.util.CaseInsensitiveComparator"/>
          </default>
          <int>1</int>
          <string>JAVA_HOME</string>
          <string>/usr/lib/jvm/java-1.8.0</string>
        </tree-map>
      </envVars>
    </hudson.slaves.EnvironmentVariablesNodeProperty>
    <org.jenkinsci.plugins.envinject.EnvInjectNodeProperty plugin="envinject@2.1.1">
      <unsetSystemVariables>false</unsetSystemVariables>
      <propertiesFilePath>${propsFilePath}</propertiesFilePath>
    </org.jenkinsci.plugins.envinject.EnvInjectNodeProperty>
  </nodeProperties>
</slave>
EOF