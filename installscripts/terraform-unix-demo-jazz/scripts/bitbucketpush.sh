#!/bin/bash

BITBUCKETELB=%1

git config --global user.email "harin.jose@ust-global.com"
git config --global user.name "jenkins1"

mkdir ./jazz-core-bitbucket
cd ./jazz-core
find . -name "*git*" -exec rm -rf '{}' \;  -print

for path in ./*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"

    echo $dirname

    curl -X POST -k -v -u "jenkins1:jenkinsadmin" -H "Content-Type: application/json" "http://$1:7990/rest/api/1.0/projects/SLF/repos" -d "{\"name\":\"$dirname\", \"scmId\": \"git\", \"forkable\": \"true\"}"

    pwd
    cd ../jazz-core-bitbucket
    pwd

    git clone http://jenkins1:jenkinsadmin@$1:7990/scm/SLF/$dirname.git

    pwd
    cp -rf ../jazz-core/$dirname/* $dirname
    cd $dirname
    pwd
    git add --all
    git commit -m 'Code from the standard template'
    git remote -v
    git push -u origin master
    echo "code has been pushed"

    pwd
    cd ../../jazz-core/

    pwd
done
