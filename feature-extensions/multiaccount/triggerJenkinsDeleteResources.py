#!/usr/bin/python
# -*- coding: utf-8 -*-

import argparse
import subprocess
import requests
import time


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--jenkins-url', help='Specify the Jenkins url')
    parser.add_argument('--jenkins-username',
                        help='Specify the Jenkins username')
    parser.add_argument('--jenkins-password',
                        help='Specify the Jenkins password')
    parser.add_argument('--account-details',
                        help='Specify the Accounts to delete')
    args = parser.parse_args()
    startJob(args)


def startJob(args):
    collectUserInput(args)
    subprocess.check_call(
        [
            "curl",
            "-sL",
            ("http://%s/jnlpJars/jenkins-cli.jar") %
            (args.jenkins_url),
            "-o",
            "jenkins-cli.jar"])
    jenkins_build_command = \
        ' java -jar jenkins-cli.jar -s http://%s '\
        '-auth %s:%s build delete-resources  -p input=%s' \
        % (args.jenkins_url, args.jenkins_username,
            args.jenkins_password, args.account_details)

    subprocess.call(jenkins_build_command, shell=True)
    if jenkins_job_status("delete-resources"):
        print "Put your autmation here for 'job is success' condition"
    else:
        print "Put your autmation here for 'job is failed' condition"


def collectUserInput(args):
    if not args.jenkins_url:
        args.jenkins_url = \
            raw_input('Please enter the Jenkins URL(without http): ')

    if not args.jenkins_username:
        args.jenkins_username = \
            raw_input('Please enter the Jenkins Username: ')

    if not args.jenkins_password:
        args.jenkins_password = \
            raw_input('Please enter the Jenkins Password: ')

    if not args.account_details:
        args.account_details = \
            raw_input('Please enter the Accounts to delete '
                      '(Empty will delete all): ') or "all"


def jenkins_job_status(job_name, args):
    try:
        url = "http://%s:%s@%s/job/%s/lastBuild/api/json" \
                % (args.jenkins_username, args.jenkins_password, args.jenkins_url, job_name)
        data = requests.get(url).json()
        if data['building']:
            time.sleep(60)
        else:
            if data['result'] == "SUCCESS":
                print "Job is success"
                return True
            else:
                print "Job status failed"
                return False
    except Exception as e:
        print str(e)
        return False


main()
