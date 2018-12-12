#!/bin/bash
# Knative Installer script
#
# Accepts docker Registry URL, credentials
# Creates Jenkins credential for the docker registry
# Updates Installer Vars with the Registry URL and credentials
# Usage: ./container-registry.sh <JENKINSELB> <Registry username> <registry password> <registry name for jenkins> <registry url> <repository> <scm user> <scm pwd> <scm elb> <jenkins user> <jenkins pwd>
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
JENKINSELB=$1
DOCKERUSER=$2
DOCKERPASSWORD=$3
DOCKERCREDID=$4
REGISTRYURL=$5
REPOSITORY=$6
SCMUSER=$7
SCMPASSWD=$8
SCMELB=$9
JENKINSUSER=${10}
JENKINSPWD=${11}

# echo "JENKINSELB..." + $JENKINSELB
# echo "DOCKERUSER..." + $DOCKERUSER
# echo "DOCKERPASSWORD..." + $DOCKERPASSWORD
# echo "DOCKERCREDID..." + $DOCKERCREDID
# echo "REGISTRYURL..." + $REGISTRYURL
# echo "SCMUSER..." + $SCMUSER
# echo "SCMPASSWD..." + $SCMPASSWD
# echo "emailid..." + $emailid
# echo "SCMELB..." + $SCMELB
# echo "JENKINSUSER..." + $JENKINSUSER
# echo "JENKINSPWD..." + $JENKINSPWD

########################### Download JENKINS CLI ############################
wget http://$JENKINSELB/jnlpJars/jenkins-cli.jar
chmod +x jenkins-cli.jar

########################### Install JQ ######################################
# Required for editing Jazz-Installer-Vars
apt-get install -y jq


# Create Jenkins Creds 
cat <<EOF |  java -jar jenkins-cli.jar -s http://$JENKINSUSER:$JENKINSPWD@$JENKINSELB/  create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>$DOCKERCREDID</id>
  <description>user credentials for Docker Registry</description>
  <username>$DOCKERUSER</username>
  <password>$DOCKERPASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

if [ ! -d "jazz-build-module" ] 
then
	# Remove only the "git" related nested files like .gitignore from all the directories
	find . -name ".git*" -exec rm -rf '{}' \;  -print
	

	# Encoded username/password for git clone
	scmuser_encoded=`python -c "import urllib; print(urllib.quote_plus('$SCMUSER'))"`
	scmpasswd_encoded=`python -c "import urllib; print(urllib.quote_plus('$SCMPASSWD'))"`
	
	
	#Clone Jazz_build-module
	git clone http://$scmuser_encoded:$scmpasswd_encoded@$SCMELB/slf/jazz-build-module 
fi

cd jazz-build-module
pwd
echo "updating jazz-installer-vars.json"

# Use jq to add registry endpoint to installer vars
jq --arg DOCKERCREDID $DOCKERCREDID --arg REGISTRYURL $REGISTRYURL --arg REPOSITORY $REPOSITORY '. |= .+ {"CONTAINER_REGISTRY": {"ENABLE_REGISTRY": true, "CREDENTIALID": $DOCKERCREDID, "REGISTRY_URL": $REGISTRYURL, "REPOSITORY": $REPOSITORY}}' jazz-installer-vars.json > tmp.$$.json && mv tmp.$$.json jazz-installer-vars.json

git add --all
git commit -m 'Update with Registry Credentials for Jenkins'
git push -u origin master
echo "Json file has been updated with Registry credentials"
