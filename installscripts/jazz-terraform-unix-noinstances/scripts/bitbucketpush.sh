#!/bin/bash

BITBUCKETELB=$1
bitbucketuser=$2
bitbucketpasswd=$3
emailid=$4
jazzbuildmodule=$5

git config --global user.email "$emailid"
git config --global user.name "$bitbucketuser"

if [ ! -d ./jazz-core-bitbucket ] ; then
  mkdir ./jazz-core-bitbucket
fi

cd ./jazz-core
find . -name "*git*" -exec rm -rf '{}' \;  -print


function individual_repo_push() {
  # Creating the repo in SLF folder in SCM
  curl -X POST -k -v -u "$bitbucketuser:$bitbucketpasswd" -H "Content-Type: application/json" "http://$BITBUCKETELB/rest/api/1.0/projects/SLF/repos" -d "{\"name\":\"$1\", \"scmId\": \"git\", \"forkable\": \"true\"}"

  # Cloning the newly created repo inside jazz-core-bitbucket folder - this sets the upstream remote repo
  cd ../jazz-core-bitbucket
  bitbucketuser_encoded=`python -c "import urllib; print(urllib.quote_plus('$bitbucketuser'))"`
  bitbucketpasswd_encoded=`python -c "import urllib; print(urllib.quote_plus('$bitbucketpasswd'))"`
  git clone http://$bitbucketuser_encoded:$bitbucketpasswd_encoded@$BITBUCKETELB/scm/SLF/$1.git

  # Updating the contents of repo inside jazz-core-bitbucket folder & pushing them to SLF folder in SCM
  cp -rf ../jazz-core/$1/* $1
  cd $1
  pwd
  git add --all
  git commit -m 'Code from the standard template'
  git remote -v
  git push -u origin master
  echo "code has been pushed"

  #Adding a temp fix for overcoming simultaneous deployment of platform services - Number of simultaneous cloudformation creation requests
  sleep 45
  cd ../../jazz-core/
}


function push_to_repo() {
  if [ "$1" == "jazz-build-module" ]; then
    individual_repo_push $1
  else
    # Initializing an array to store the order of directories to be pushed into SLF folder in SCM. "jazz-build-module" is already pushed at this stage.
    repos=("serverless-config-pack" "cognito-authorizer")

    # Appending all the other repos to the array
    for d in */ ; do
        if [[ ${d%/} != "jazz-build-module" && ${d%/} != "cognito-authorizer" && ${d%/} != "serverless-config-pack" && ${d%/} != "build-deploy-platform-services" ]]; then
          repos+=("${d%/}")
        fi
    done

    # Push to SLF by traversing the array
    for dirname in "${repos[@]}"
    do
      individual_repo_push $dirname
    done
  fi
}

push_to_repo $jazzbuildmodule
