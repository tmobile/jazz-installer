JENKINS_URL=http://$1/ # localhost or jenkins elb url
JENKINS_CLI=$2
AUTHFILE=$3

echo "$0 $1 $2 $3"
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-credentials-by-xml system::system::jenkins "(global)"
        <com.dabsquared.gitlabjenkins.connection.GitLabApiTokenImpl plugin="gitlab-plugin@1.5.2">
          <scope>GLOBAL</scope>
          <id>Jazz-Gitlab-API-Cred</id>
          <description>Jazz-Gitlab-API-Cred</description>
          <apiToken>replace</apiToken>
        </com.dabsquared.gitlabjenkins.connection.GitLabApiTokenImpl>
EOF
