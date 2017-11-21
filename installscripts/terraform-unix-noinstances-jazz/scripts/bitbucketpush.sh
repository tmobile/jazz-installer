#!/bin/bash

BITBUCKETELB=%1
bitbucketuser=$2
bitbucketpasswd=$3

git config --global user.email "harin.jose@ust-global.com"
git config --global user.name "$bitbucketuser"

mkdir ./jazz-core-bitbucket
cd ./jazz-core
find . -name "*git*" -exec rm -rf '{}' \;  -print

for path in ./*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"

    echo $dirname

    curl -X POST -k -v -u "$bitbucketuser:$bitbucketpasswd" -H "Content-Type: application/json" "http://$1:7990/rest/api/1.0/projects/SLF/repos" -d "{\"name\":\"$dirname\", \"scmId\": \"git\", \"forkable\": \"true\"}"

    pwd
    cd ../jazz-core-bitbucket
    pwd

    bitbucketuser_encoded=`python -c "import urllib; print(urllib.quote_plus('$bitbucketuser'))"`
    bitbucketpasswd_encoded=`python -c "import urllib; print(urllib.quote_plus('$bitbucketpasswd'))"`
    git clone http://$bitbucketuser_encoded:$bitbucketpasswd_encoded@$1:7990/scm/SLF/$dirname.git

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
