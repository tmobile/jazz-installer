#!/bin/bash

BITBUCKETELB=$1
bitbucketuser=$2
bitbucketpasswd=$3
emailid=$4

git config --global user.email "$emailid"
git config --global user.name "$bitbucketuser"

mkdir ./jazz-core-bitbucket
cd ./jazz-core
find . -name "*git*" -exec rm -rf '{}' \;  -print

# Initializing an array to store the order of directories to be pushed into SLF folder in SCM
repos=("jazz-build-module" "cognito-authorizer")

# Appending all the other repos to the array
for d in */ ; do
    if [[ ${d%/} != "jazz-build-module" && ${d%/} != "cognito-authorizer" ]]; then
      repos+=("${d%/}")
    fi
done

# Push to SLF by traversing the array
for dirname in "${repos[@]}"
do
    # Creating the repo in SLF folder in SCM
    curl -X POST -k -v -u "$bitbucketuser:$bitbucketpasswd" -H "Content-Type: application/json" "http://$1/rest/api/1.0/projects/SLF/repos" -d "{\"name\":\"$dirname\", \"scmId\": \"git\", \"forkable\": \"true\"}"

    # Cloning the newly created repo inside jazz-core-bitbucket folder - this sets the upstream remote repo
    cd ../jazz-core-bitbucket
    bitbucketuser_encoded=`python -c "import urllib; print(urllib.quote_plus('$bitbucketuser'))"`
    bitbucketpasswd_encoded=`python -c "import urllib; print(urllib.quote_plus('$bitbucketpasswd'))"`
    git clone http://$bitbucketuser_encoded:$bitbucketpasswd_encoded@$BITBUCKETELB/scm/SLF/$dirname.git

    # Updating the contents of repo inside jazz-core-bitbucket folder & pushing them to SLF folder in SCM
    cp -rf ../jazz-core/$dirname/* $dirname
    cd $dirname
    pwd
    git add --all
    git commit -m 'Code from the standard template'
    git remote -v
    git push -u origin master
    echo "code has been pushed"

    #Adding a temp fix for overcoming simultaneous deployment of platform services - Number of simultaneous cloudformation creation requests
    sleep 10
    cd ../../jazz-core/
done
