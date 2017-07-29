JENKINS_URL=http://$1:8080/ # localhost or jenkins elb url
AUTHFILE=/home/ec2-user/cookbooks/jenkins/files/default/authfile
JENKINS_CLI=/home/ec2-user/jenkins-cli.jar
echo "$0 $1 $2 "
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.SystemCredentialsProvider plugin="credentials@2.1.14">
  <domainCredentialsMap class="hudson.util.CopyOnWriteMap$Hash">
    <entry>
      <com.cloudbees.plugins.credentials.domains.Domain>
        <specifications/>
      </com.cloudbees.plugins.credentials.domains.Domain>
      <java.util.concurrent.CopyOnWriteArrayList>
        <com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
          <scope>GLOBAL</scope>
          <id>642cdc8d-a9f4-4f80-b73c-863ccd522765</id>
          <description>user created on bitbucket</description>
          <username>jenkins1</username>
          <password>{AQAAABAAAAAQ3xUYEheZyvXW1lwQwAo9SXLAvFdExghI11bRoUCFNaw=}</password>
        </com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
        <com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl plugin="aws-credentials@1.21">
          <scope>GLOBAL</scope>
          <id>2c88b8e9-52f7-467a-b276-b29fe38bc95f2213</id>
          <description>AWS Credentials</description>
          <accessKey>AKIAI3PSMBAWFO25T2XQ</accessKey>
          <secretKey>{AQAAABAAAAAwdr81k7zPdmG5hvAljPxIeNQfBHRjPr7ngUpXF1DyfWsVQTF8pqUdno/IZH9XjsjXVHcC9X/FqJFK4dDm0ku/Qw==}</secretKey>
          <iamRoleArn></iamRoleArn>
          <iamMfaSerialNumber></iamMfaSerialNumber>
        </com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl>
      </java.util.concurrent.CopyOnWriteArrayList>
    </entry>
  </domainCredentialsMap>
</com.cloudbees.plugins.credentials.SystemCredentialsProvider>
EOF