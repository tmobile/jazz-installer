#!/bin/bash
mkdir ../jazz-core-bitbucket

for path in ./*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"
    
    echo $dirname
  
    curl -X POST -k -v -u "bitbucketuser:password" -H "Content-Type: application/json" "http://bitbucketelb-1507445866.us-east-2.elb.amazonaws.com/rest/api/1.0/projects/TEST/repos" -d "{\"name\":\"$dirname\", \"scmId\": \"git\", \"forkable\": \"true\"}"
   
    pwd
    cd ../jazz-core-bitbucket
    pwd
   
    git clone http://bitbucketuser:password@bitbucketelb-1507445866.us-east-2.elb.amazonaws.com/scm/test/$dirname.git

    pwd   
    cp -rf ../jazz-core-git/$dirname/* $dirname
    cd $dirname
    pwd
    git add --all
    git commit -m 'Code from the standard template'
    git remote -v
    git push -u origin master
    echo "code has been pushed"

    pwd
    cd ../../jazz-core-git/

    pwd
done
