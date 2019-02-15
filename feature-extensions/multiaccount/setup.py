#!/usr/bin/env python2
import argparse
import subprocess
from api_config import update_config
from core import deploy_core_service


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


featureName = "MultiAccount"


def main():
    # TODO replace argparse stuff and manual arg validation checking with Click once main installer rewrite is done
    mainParser = argparse.ArgumentParser()
    mainParser.description = ('Installs the MultiAccount extension for the Jazz Serverless Development Platform '
                              '(https://github.com/tmobile/jazz)')
    subparsers = mainParser.add_subparsers(help='Installation scenarios', dest='command')

    subparsers.add_parser('install', help='Install feature extension').set_defaults(func=install)

    mainParser.add_argument(
        '--jazz-stackprefix',
        help='Specify the stackprefix of your existing Jazz installation (e.g. myjazz), \
              your existing config will be imported'
    )

    mainParser.add_argument(
        '--aws-region',
        nargs='+',
        help='Specify the regions.'
    )
    mainParser.add_argument("--aws-accesskey", help="AWS accesskey of the new account")
    mainParser.add_argument("--aws-secretkey", help="AWS secretkey of the new account")

    mainParser.add_argument(
        '--jenkins-url',
        help='Specify the Jenkins url'
    )

    mainParser.add_argument(
        '--jenkins-username',
        help='Specify the Jenkins username'
    )

    mainParser.add_argument(
        '--jenkins-password',
        help='Specify the Jenkins password'
    )

    mainParser.add_argument(
        '--jazz-username',
        help='Specify the Jazz username'
    )

    mainParser.add_argument(
        '--jazz-password',
        help='Specify the Jazz password'
    )

    mainParser.add_argument(
        '--jazz-apiendpoint',
        help='Specify the Jazz password'
    )

    args = mainParser.parse_args()
    args.func(args)


def install(args):
    print(
        colors.OKGREEN +
        "\nThis will install {0} functionality into your Jazz deployment.\n".format(featureName)
        + colors.ENDC)

    collect_userinputs(args)
    account_json, credential_id = deploy_core_service(args)

    # Store the CREDENTIAL_ID in jenkins
    setCredential(args, credential_id)
    print account_json
    update_config(
        "AWS.ACCOUNTS",
        account_json,
        args.jazz_username,
        args.jazz_password,
        args.jazz_apiendpoint
    )


def collect_userinputs(args):

    if not args.jazz_stackprefix:
        args.jazz_stackprefix = raw_input("Please enter the environment prefix you used for your Jazz install: ")

    if not args.aws_accesskey:
        args.aws_accesskey = raw_input("Enter AWS accesskey of the new account:")

    if not args.aws_secretkey:
        args.aws_secretkey = raw_input("Enter secretkey of the new account:")

    if not args.aws_region:
        args.aws_region = raw_input("Enter AWS regions with space delimiter:").split()

    if not args.jenkins_url:
        args.jenkins_url = raw_input("Please enter the Jenkins URL(without http): ")

    if not args.jenkins_username:
        args.jenkins_username = raw_input("Please enter the Jenkins Username: ")

    if not args.jenkins_password:
        args.jenkins_password = raw_input("Please enter the Jenkins Password: ")

    if not args.jazz_username:
        args.jazz_username = raw_input("Please enter the Jazz Admin Username: ")

    if not args.jazz_password:
        args.jazz_password = raw_input("Please enter the Jazz Admin Password: ")

    if not args.jazz_apiendpoint:
        args.jazz_apiendpoint = raw_input("Please enter the Jazz API Endpoint(Full URL): ")

    return args


def setCredential(args, credential_id):
    subprocess.check_call(
        [
            "curl",
            "-sL",
            ("http://%s/jnlpJars/jenkins-cli.jar") %
            (args.jenkins_url),
            "-o",
            "jenkins-cli.jar"])
    jenkins_cli_command = "java -jar jenkins-cli.jar -auth %s:%s -s  http://%s" % (
                          args.jenkins_username,
                          args.jenkins_password,
                          args.jenkins_url)
    subprocess.check_call(
        [
            "bash",
            "account_cred.sh",
            "%s" % (jenkins_cli_command),
            credential_id,
            args.aws_accesskey,
            args.aws_secretkey
            ])


main()
