#!/bin/bash
jenkins_url="http://Jenkins-terraform-elb-209020953.us-east-1.elb.amazonaws.com"
cli_url="$jenkins_url:8080/jnlpJars/jenkins-cli.jar"
jenkins_username="{jenkinsuser}"
jenkins_password="{jenkinspasswd}"

bb_url="http://bitbucket-terraform-elb-1577123782.us-east-1.elb.amazonaws.com"
bb_username="{bitbucketuser}"
bb_password="{bitbucketpasswd}"
script_path="/home/ec2-user/atlassian-cli-6.7.1/bitbucket.sh"

delete_repos () {
    sudo $script_path --server $bb_url --user $bb_username --password $bb_password --action getRepositoryList --project "$1" | grep -i $1 | awk -F',' '{print $2}' | tr -d '"' > repolist
    while read p; do
    sudo $script_path --server $bb_url --user $bb_username --password $bb_password  --action deleteRepository --project "$1" --repository "$p"
    done < repolist
}

delete_bb_all () {
    sudo $script_path --server $bb_url --user $bb_username --password $bb_password --action getProjectlist | grep -i /projects | awk -F ',' '{print $2}' | tr
-d '"' > projectlist
    while read q; do
    delete_repos "$q"
    sudo $script_path --server $bb_url --user $bb_username --password $bb_password --action deleteProject --project "$q"
    done < projectlist

    rm -rf projectlist repolist
}

delete_jenkins_jobs () {
    /usr/bin/curl -s $cli_url --output jenkins-cli.jar
    /usr/bin/java -jar jenkins-cli.jar -s $jenkins_url list-jobs --username $jenkins_username --password $jenkins_password > jobslist
    while read r; do
    /usr/bin/java -jar jenkins-cli.jar -s $jenkins_url delete-job "$r" --username $jenkins_username --password $jenkins_password &
    done < jobslist
    rm -rf jobslist
}

delete_bb_all
delete_jenkins_jobs
