#!/bin/bash
#General variables
scmelb=$1
scmuser=$2
scmpasswd=$3
emailid=$4

#Gitlab Specific
token=$5
ns_id_slf=$6

# Config variables
scm=$7
jenkins_elb=$8
jenkins_user=$9
jenkins_password=${10}
jazzbuildmodule=${11}
gitlab_trigger_job_url="/project/Gitlab-Trigger-Job"
gitlab_webhook_url="http://$jenkins_user:$jenkins_password@$jenkins_elb$gitlab_trigger_job_url"
platform_services=("cognito-authorizer" "platform_logs" "platform_usermanagement" "platform-services-handler" "platform_events" "platform_services" "platform_logout" "platform_login" "cloud-logs-streamer" "is-service-available" "delete-serverless-service" "create-serverless-service" "platform_email" )

git config --global user.email "$emailid"
git config --global user.name "$scmuser"

#Encoded username/password for git clone
scmuser_encoded=`python -c "import urllib; print(urllib.quote_plus('$scmuser'))"`
scmpasswd_encoded=`python -c "import urllib; print(urllib.quote_plus('$scmpasswd'))"`

if [ ! -d ./jazz-core-scm ] ; then
  mkdir ./jazz-core-scm
fi

cd ./jazz-core

# Remove only the "git" related nested files like .gitignore from all the directories in jazz-core
find . -name ".git*" -exec rm -rf '{}' \;  -print

# Function to push code to individual repos in SLF projects to SCM
function individual_repopush() {
  cd ../jazz-core-scm
  if [ $scm == "bitbucket" ]; then
    # Creating the repo in SLF folder in SCM
    curl -X POST -k -v -u "$scmuser:$scmpasswd" -H "Content-Type: application/json" "http://$scmelb/rest/api/1.0/projects/SLF/repos" -d "{\"name\":\"$1\", \"scmId\": \"git\", \"forkable\": \"true\"}"
    # Cloning the newly created repo inside jazz-core-scm folder - this sets the upstream remote repo
    git clone http://$scmuser_encoded:$scmpasswd_encoded@$scmelb/scm/SLF/$1.git

  elif [ $scm == "gitlab" ]; then
    # Creating the repo in SLF folder in SCM
    repo_id=$(curl -sL --header "PRIVATE-TOKEN: $token" -X POST "http://$scmelb/api/v4/projects?name=$1&namespace_id=$ns_id_slf" | awk -F',' '{print $1}'| awk -F':' '{print $2}')
	if [[ " ${platform_services[*]} " == *" $1 "* ]]; then
		#Adding webhook to the repo
		curl --header "PRIVATE-TOKEN: $token" -X POST "http://$scmelb/api/v4/projects/$repo_id/hooks?enable_ssl_verification=false&push_events=true&url=$gitlab_webhook_url"
	fi 
	# Cloning the newly created repo inside jazz-core-scm folder - this sets the upstream remote repo
    git clone http://$scmuser_encoded:$scmpasswd_encoded@$scmelb/slf/$1.git
  fi

  # Updating the contents of repo inside jazz-core-scm folder & pushing them to SLF folder in SCM
  cp -rf ../jazz-core/$1/* $1
  cd $1
  pwd
  git add --all
  git commit -m 'Code from the standard template'
  git remote -v
  git push -u origin master
  echo "code has been pushed"

  # Adding a sleep to ensure smaller jenkins boxes do not overload themselves.
  sleep 45
  cd ../../jazz-core/
}

function push_to_scm() {
  if [[ "$1" == "jazz-build-module" && "$scm" == "bitbucket" ]]; then
    individual_repopush $1
  elif [[ "$1" == "jazz-build-module" && "$scm" == "gitlab" ]]; then
    individual_repopush $1
  else
    # Initializing an array to store the order of directories to be pushed into SLF folder in SCM. This is common for all repos.
    # "jazz-build-module" is already pushed at this stage.
    repos=("serverless-config-pack" "jenkins-build-pack-api" "jenkins-build-pack-lambda")

    # Including SCM specific repos
    if [ $scm == "gitlab" ]; then
      repos+=("gitlab-build-pack")
    fi

	repos+=("cognito-authorizer")
	
    # Appending all the other repos to the array
    for d in */ ; do
        if [[ ${d%/} != "jazz-build-module" && ${d%/} != "cognito-authorizer" && ${d%/} != "serverless-config-pack" && ${d%/} != "jenkins-build-pack-api" && ${d%/} !=  "jenkins-build-pack-lambda" && ${d%/} != "gitlab-build-pack" ]]; then
          repos+=("${d%/}")
        fi
    done

    # Push to SLF by traversing the array
    for dirname in "${repos[@]}"
    do
      individual_repopush $dirname
    done
  fi
}

push_to_scm $jazzbuildmodule
