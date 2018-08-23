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
apikey=${11}
region=${12}
jazzbuildmodule=${13}

webhook_url="https://$apikey.execute-api.$region.amazonaws.com/prod/jazz/scm-webhook"

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
    reponame="${1##*/}"
    parentfolder="${1%/*}"

    if [ $scm == "bitbucket" ]; then
        # Creating the repo in SLF folder in SCM
        curl -X POST -k -v -u "$scmuser:$scmpasswd" -H "Content-Type: application/json" "http://$scmelb/rest/api/1.0/projects/SLF/repos" -d "{\"name\":\"$reponame\", \"scmId\": \"git\", \"forkable\": \"true\"}"
        # Adding webhook to the jazz core services
        curl -X PUT -k -v -u "$scmuser:$scmpasswd" -H "Content-Type: application/json" "http://$scmelb/rest/webhook/1.0/projects/SLF/repos/$reponame/configurations"  -d "{\"title\": \"notify-events\", \"url\": \"$webhook_url\" , \"enabled\": true}"
        # Cloning the newly created repo inside jazz-core-scm folder - this sets the upstream remote repo
        git clone http://$scmuser_encoded:$scmpasswd_encoded@$scmelb/scm/SLF/$reponame.git

    elif [ $scm == "gitlab" ]; then
        # Creating the repo in SLF folder in SCM
        repo_id=$(curl -sL --header "PRIVATE-TOKEN: $token" -X POST "http://$scmelb/api/v4/projects?name=$reponame&namespace_id=$ns_id_slf" | awk -F',' '{print $1}'| awk -F':' '{print $2}')
        # Adding webhook to the jazz core services
        curl --header "PRIVATE-TOKEN: $token" -X POST "http://$scmelb/api/v4/projects/$repo_id/hooks?enable_ssl_verification=false&push_events=true&url=$webhook_url"
        # Cloning the newly created repo inside jazz-core-scm folder - this sets the upstream remote repo
        git clone http://$scmuser_encoded:$scmpasswd_encoded@$scmelb/slf/$reponame.git
    fi

    # Updating the contents of repo inside jazz-core-scm folder & pushing them to SLF folder in SCM
    cp -rf ../jazz-core/$1/. $reponame
    cd $reponame
    pwd
    git add --all
    git commit -m 'Code from the standard template'
    git remote -v
    git push -u origin master
    echo "code has been pushed"

    # Adding a sleep to ensure smaller jenkins boxes do not overload themselves,
    # and to work around the AWS API Gateway creation limit:
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html
    # since micro services are now only in the core folder, giving sleep for core folder.
    if [[ $parentfolder == "core" ]]; then
        sleep 45
        if [[ $reponame == "jazz_ui" ]]; then
            curl -X POST  "http://$jenkins_user:$jenkins_password@$jenkins_elb/job/jazz_ui/build?token=jazz-101-job"
        elif [[ $reponame != "jazz-web" ]]; then
            file=`find . -type f -name "build.*"`
            file_name=${file#*/}
            service_type="${file_name:6}"
            service_name="${reponame:5}"
            curl -X POST  "http://$jenkins_user:$jenkins_password@$jenkins_elb/job/build-pack-$service_type/buildWithParameters?token=jazz-101-job&service_name=$service_name&domain=jazz&scm_branch=master"
        fi
    fi
    cd ../../jazz-core/
}

function push_to_scm() {
    if [[ "$1" == "builds" ]] ; then
        repos=()
        for d in builds/* ; do
           repos+=("${d%/}")
        done
        # Push builds to SLF by traversing the array
        for dirname in "${repos[@]}"
        do
          individual_repopush $dirname
        done
    else
        # Initializing an array to store the order of directories to be pushed into SLF folder in SCM. This is common for all repos.
        # "builds" is already pushed at this stage.
        repos=()
        # Including dependent repos first
        for d in core/* ; do
            if [[ ${d%/} =~ "jazz_cognito-authorizer" ]] || [[ ${d%/} =~ "jazz_cloud-logs-streamer" ]] || [[ ${d%/} =~ "jazz_ui" ]] ; then
              repos+=("${d%/}")
            fi
        done

        for d in **/*/ ; do
            if [[ ! ${d%/} =~ "jazz_cognito-authorizer" ]] && [[ ! ${d%/} =~ "jazz_cloud-logs-streamer" ]] && [[ ! ${d%/} =~ "jazz_ui" ]] && [[ ! ${d%/} =~ "jazz_scm-webhook" ]] ; then
                repos+=("${d%/}")
            fi
            if [[ ${d%/} =~ "jazz_scm-webhook" ]] ; then
                last_repo="${d%/}"
            fi
        done

        # Pushing jazz_scm-webhook as the last repo
        repos+=("$last_repo")

        # Push to SLF by traversing the array
        for dirname in "${repos[@]}"
        do
         if [[ "${dirname%/*}" != "builds" ]] ; then
           individual_repopush $dirname
         fi
        done
    fi
}

push_to_scm $jazzbuildmodule
