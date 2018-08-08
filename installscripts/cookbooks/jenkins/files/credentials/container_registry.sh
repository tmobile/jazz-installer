JENKINS_CLI_CMD=$1
DOCKERUSER=$2
DOCKERPASSWORD=$3
DOCKERCREDID=$4
REGISTRYURL=$5
SCMUSER=$5
SCMPASSWD=$6
emailid=$7
SCMELB=$8


cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
#cat <<EOF |  java -jar jenkins-cli.jar -s http://dbabu:Wsxqaz12#@34.229.106.88:8080/  create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>$DOCKERCREDID</id>
  <description>user credentials for Docker Registry</description>
  <username>$DOCKERUSER</username>
  <password>$DOCKERPASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

# Remove only the "git" related nested files like .gitignore from all the directories in jazz-core
find . -name ".git*" -exec rm -rf '{}' \;  -print

#Clone Jazz_build-module
git clone http://$SCMUSER:$SCMPASSWD@$SCMELB/slf/jazz-build-module.git
cd jazz-build-module
pwd
echo "updating jazz-installer-vars.json"
jenkinsJsonfile= jazz-installer-vars.json
sed -i '/CREDENTIALID"/c\   \"CREDENTIALID"\" : \"$DOCKERCREDID\",' jazz-installer-vars.json
sed -i '/url"/c\   \"url"\" : \"$REGISTRYURL\",' jazz-installer-vars.json
git add --all
git commit -m 'Update with Registry Credentials for Jenkins'
git push -u origin master
echo "Json file has been updated with Registry credentials"