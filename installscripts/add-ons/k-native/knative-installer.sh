#!/bin/bash
# Knative Installer script
#
# Installs Gcloud CLI
# Installs KubeCTL
# Accepts Gcloud Service account Key
# Sets up KubeCTL by pulling the credentials for the Knative Kubernetes cluster deployments
# Creates Jenkins credential for the K-native cluster service account
# Updates Installer Vars with the K-native endpoint and credential details
# Usage: ./knative-installer.sh --key-file <path to key file> --gcld-project <project name> --cluster <cluster name> --zone <zone> --scm-user <scm username> --scm-pwd <scm password> --emailid <scm email id> --scmelb <scm elb uri> --jenkins-user <jenkins user> --jenkins-pwd <jenkins password> --jenkins-elb <jenkins elb>"
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

usage()
{
    echo "usage: ./knative-installer.sh --key-file <path to key file> --gcld-project <project name> --cluster <cluster name> --zone <zone> --scm-user <scm username> --scm-pwd <scm password> --emailid <scm email id> --scmelb <scm elb uri> --jenkins-user <jenkins user> --jenkins-pwd <jenkins password> --jenkins-elb <jenkins elb>"
}

if [ "$1" == "" ]; then
   usage
   exit 1
fi

while [ "$1" != "" ]; do
   case $1 in
   
		-k | --key-file )       shift
								filename=$1
								;;
		-p | --gcld-project )	shift
								project=$1
								;;
		-c | --cluster ) 		shift
								cluster=$1
								;;
		-z | --zone ) 			shift
								zone=$1
								;;
		-su | --scm-user )		shift
								scmuser=$1
								;;
		-sp | --scm-pwd )		shift
								scmpwd=$1
								;;
		-em | --emailid )		shift
								emailid=$1
								;;
		-scm | --scmelb ) 		shift
								scmelb=$1
								;;
		-ju | --jenkins-user )	shift
								jenkinsuser=$1
								;;
		-jp | --jenkins-pwd )	shift
								jenkinspwd=$1
								;;
		-j | --jenkins-elb )	shift
								jenkinselb=$1
								;;
		-h | --help )           usage
								exit
								;;
		* )                     usage
								exit 1
   esac
   shift
done



if [ "$filename" == "" ] || [ "$project" == "" ] || [ "$cluster" == "" ] || [ "$zone" == "" ] || [ "$scmuser" == "" ] || [ "$scmpwd" == "" ] || [ "$emailid" == "" ] || [ "$scmelb" == "" ] || [ "$jenkinsuser" == "" ] || [ "$jenkinspwd" == "" ] || [ "$jenkinselb" == "" ]; then
   usage
   exit 1
fi


######################### GCLOUD CLI INSTALLATION ###########################
# Create environment variable for correct distribution
# Add the Cloud SDK distribution URI as a package source
# Import the Google Cloud Platform public key
# Update the package list and install the Cloud SDK
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk -y

######################## KUBECTL INSTALLATION ###############################
# Create Kubernetes source list if it does not exist
# Add KubeCTL distribution as a package source
# Update package list and install KubeCTL
apt-get install -y apt-transport-https && \
	touch /etc/apt/sources.list.d/kubernetes.list && \
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
	sudo apt-get update -y && sudo apt-get install -y kubectl


########################### Install JQ ######################################
# Required for editing Jazz-Installer-Vars
apt-get install -y jq


# use jq to read the key-file
private_key_id=($(jq -r '.private_key_id' $filename))
private_key=($(jq -r '.private_key' $filename))

type=($(jq -r '.type' $filename))
project_id=($(jq -r '.project_id' $filename))
client_email=($(jq -r '.client_email' $filename))
client_id=($(jq -r '.client_id' $filename))
auth_uri=($(jq -r '.auth_uri' $filename))
token_uri=($(jq -r '.token_uri' $filename))
auth_provider_x509_cert_url=($(jq -r '.auth_provider_x509_cert_url' $filename))
client_x509_cert_url=($(jq -r '.client_x509_cert_url' $filename))


########################## Create credential in Jenkins ###############
# Download jenkins CLI
wget http://$jenkinselb/jnlpJars/jenkins-cli.jar
chmod +x jenkins-cli.jar

knativecred=$(cat /proc/sys/kernel/random/uuid)

cat <<EOF |  java -jar jenkins-cli.jar -s http://$jenkinsuser:$jenkinspwd@$jenkinselb/  create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>$knativecred</id>
  <description>user credentials for Default Knative Cluster</description>
  <username>$private_key_id</username>
  <password>${private_key[@]}</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

########################### GCLOUD AND KUBECTL CONFIGURATION ################
# activate GCloud service account
gcloud auth activate-service-account --key-file $filename

# get credentials for your kubernetes cluster
gcloud container clusters get-credentials $cluster --zone $zone --project $project

# test kubectl config
kubectl config view


########################### UPDATE INSTALLER VARS ###########################

# Remove only the "git" related nested files like .gitignore from all the directories
find . -name ".git*" -exec rm -rf '{}' \;  -print

git config --global user.email "$emailid"
git config --global user.name "$scmuser"

# Encoded username/password for git clone
scmuser_encoded=`python -c "import urllib; print(urllib.quote_plus('$scmuser'))"`
scmpasswd_encoded=`python -c "import urllib; print(urllib.quote_plus('$scmpwd'))"`

# Clone Jazz_build-module
git clone http://$scmuser_encoded:$scmpasswd_encoded@$scmelb/slf/jazz-build-module
cd jazz-build-module
echo "updating jazz-installer-vars.json"

# Use jq to add default knative endpoint to installer vars
echo $knativecred



jq --arg project $project --arg cluster $cluster --arg zone $zone --arg knativecred $knativecred  --arg type $type --arg project_id $project_id --arg client_email $client_email --arg client_id $client_id --arg auth_uri $auth_uri --arg token_uri $token_uri --arg auth_provider_x509_cert_url $auth_provider_x509_cert_url --arg client_x509_cert_url $client_x509_cert_url '. |= .+ {"KNATIVE": {"ENABLE_KNATIVE" : true, "ENDPOINTS" : [ {"NAME": "default", "PROJECT": $project, "CLUSTER": $cluster, "ZONE": $zone, "CREDENTIALID": $knativecred, "PRIVATE_KEY_ATTRIBUTES": {"type": $type, "project_id": $project_id, "client_email": $client_email, "client_id": $client_id, "auth_uri": $auth_uri, "token_uri": $token_uri, "auth_provider_x509_cert_url": $auth_provider_x509_cert_url, "client_x509_cert_url": $client_x509_cert_url } }]}}' jazz-installer-vars.json > tmp.$$.json && mv tmp.$$.json jazz-installer-vars.json

# Push installer-vars to scm
git add --all
git commit -m 'Updated installer-vars with default knative endpoint'
git push -u origin master
echo "Updated installer-vars with default knative endpoint"