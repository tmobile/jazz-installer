#!/usr/bin/env python2
import boto3
import argparse
import subprocess
from git_config import replace_config


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
        '--aws-region',
        nargs='+',
        help='Specify the regions.'
    )
    mainParser.add_argument("--aws-accesskey", help="AWS accesskey of the new account")
    mainParser.add_argument("--aws-secretkey", help="AWS secretkey of the new account")
    mainParser.add_argument(
        '--scm-repo',
        help='Specify the scm repo url'
    )

    mainParser.add_argument(
        '--scm-username',
        help='Specify the scm username'
    )

    mainParser.add_argument(
        '--scm-password',
        help='Specify the scm password'
    )

    mainParser.add_argument(
        '--scm-pathext',
        help='Specify the scm repo path ext (Use "scm" for bitbucket)'
    )

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

    args = mainParser.parse_args()
    args.func(args)


def install(args):
    print(
        colors.OKGREEN +
        "\nThis will install {0} functionality into your Jazz deployment.\n".format(featureName)
        + colors.ENDC)

    collect_userinputs(args)
    account_user = getAccountUser(args.aws_accesskey, args.aws_secretkey)
    account_user_arn = getAccountUserArn(args.aws_accesskey, args.aws_secretkey)
    account_id = getAccountId(args.aws_accesskey, args.aws_secretkey)
    credential_id = "MultiAccount"+account_id
    # prepare account json with account and regions
    account_json = {"ACCOUNTID": account_id,
                    "CREDENTIAL_ID": credential_id,
                    "IAM": {"USER": account_user, "USER_ARN": account_user_arn},
                    "REGIONS": args.aws_region
                    }
    # Store the CREDENTIAL_ID in jenkins
    setCredential(args, credential_id)

    replace_config(
        account_json,
        args.scm_repo,
        args.scm_username,
        args.scm_password,
        args.scm_pathext
    )


def collect_userinputs(args):

    if not args.aws_accesskey:
        args.aws_accesskey = raw_input("Enter AWS accesskey of the new account:")

    if not args.aws_secretkey:
        args.aws_secretkey = raw_input("Enter secretkey of the new account:")

    if not args.aws_region:
        args.aws_region = raw_input("Enter AWS regions with space delimiter:").split()

    if not args.scm_repo:
        args.scm_repo = raw_input("Please enter the SCM Repo: ")

    if not args.scm_username:
        args.scm_username = raw_input("Please enter the SCM Username: ")

    if not args.scm_password:
        args.scm_password = raw_input("Please enter the SCM Password: ")

    if not args.scm_pathext:
        args.scm_pathext = raw_input("Please enter the SCM Pathext (Use \"/scm\" for bitbucket): ") or "/"

    if not args.jenkins_url:
        args.jenkins_url = raw_input("Please enter the Jenkins URL: ")

    if not args.jenkins_username:
        args.jenkins_username = raw_input("Please enter the Jenkins Username: ")

    if not args.jenkins_password:
        args.jenkins_password = raw_input("Please enter the Jenkins Password: ")

    return args


def getAccountUser(accessKey, secretKey):
    obj_iam = boto3.resource('iam', aws_access_key_id=accessKey, aws_secret_access_key=secretKey)
    return obj_iam.CurrentUser().user_name


def getAccountUserArn(accessKey, secretKey):
    obj_iam = boto3.resource('iam', aws_access_key_id=accessKey, aws_secret_access_key=secretKey)
    return obj_iam.CurrentUser().arn


def getAccountId(accessKey, secretKey):
    return boto3.client('sts',
                        aws_access_key_id=accessKey,
                        aws_secret_access_key=secretKey).get_caller_identity().get('Account')


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
