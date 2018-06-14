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
jazz_ui_trigger_job_url="/project/jazz_ui"

gitlab_webhook_url="http://$jenkins_user:$jenkins_password@$jenkins_elb$gitlab_trigger_job_url"
gitlab_jazz_ui_webhook_url="http://$jenkins_user:$jenkins_password@$jenkins_elb$jazz_ui_trigger_job_url"

platform_services=("jazz_cognito-authorizer" "jazz_logs" "jazz_usermanagement" "jazz_services-handler" "jazz_events" "jazz_services" "jazz_logout" "jazz_login" "jazz_cloud-logs-streamer" "jazz_is-service-available" "jazz_delete-serverless-service" "jazz_create-serverless-service" "jazz_email" "jazz_events-handler" "jazz_environments" "jazz_scm-webhook" "jazz_environment-event-handler" "jazz_deployments" "jazz_deployments-event-handler" "jazz_assets" "jazz_asset-event-handler")

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

        # Adding webhook to the platform services and separate webhook for jazz_ui repo
        if [[ " ${platform_services[*]} " == *" $1 "* ]]; then
            curl --header "PRIVATE-TOKEN: $token" -X POST "http://$scmelb/api/v4/projects/$repo_id/hooks?enable_ssl_verification=false&push_events=true&url=$gitlab_webhook_url"
        elif [[ "$1" == "jazz-ui" ]]; then
            curl --header "PRIVATE-TOKEN: $token" -X POST "http://$scmelb/api/v4/projects/$repo_id/hooks?enable_ssl_verification=false&push_events=true&url=$gitlab_jazz_ui_webhook_url"
        fi

        # Cloning the newly created repo inside jazz-core-scm folder - this sets the upstream remote repo
        git clone http://$scmuser_encoded:$scmpasswd_encoded@$scmelb/slf/$1.git
    fi

    # Updating the contents of repo inside jazz-core-scm folder & pushing them to SLF folder in SCM
    cp -rf ../jazz-core/$1/. $1
    cd $1
    pwd
    git add --all
    git commit -m 'Code from the standard template'
    git remote -v
    git push -u origin master
    echo "code has been pushed"

    # Adding a sleep to ensure smaller jenkins boxes do not overload themselves,
    # and to work around the AWS API Gateway creation limit:
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html
    # TODO this drastically inflates install time, look into ways to reduce this wait.
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

        repos+=("jazz_cognito-authorizer")

        # Appending all the other repos to the array
        for d in */ ; do
            if [[ ${d%/} != "jazz-build-module" && ${d%/} != "jazz_cognito-authorizer" && ${d%/} != "serverless-config-pack" && ${d%/} != "jenkins-build-pack-api" && ${d%/} !=  "jenkins-build-pack-lambda" && ${d%/} != "gitlab-build-pack" ]]; then
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
