#!/usr/bin/env python2
import subprocess
import argparse
import urllib


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


featureName = "Splunk"


def main():
    mainParser = argparse.ArgumentParser()
    mainParser.description = ('Installs the Splunk extension for the Jazz Serverless Development Platform '
                              '(https://github.com/tmobile/jazz)')
    subparsers = mainParser.add_subparsers(help='Installation scenarios', dest='command')

    subparsers.add_parser('install', help='Install feature extension').set_defaults(func=install)

    mainParser.add_argument(
        '--splunk-endpoint',
        help='Specify the splunk endpoint'
    )
    mainParser.add_argument(
        '--splunk-token',
        help='Specify the splunk token'
    )
    mainParser.add_argument(
        '--splunk-index',
        help='Specify the splunk index'
    )
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

    args = mainParser.parse_args()
    args.func(args)


def install(args):
    print(
        colors.OKGREEN +
        "\nThis will install {0} functionality into your Jazz deployment.\n".format(featureName)
        + colors.ENDC)

    configureSplunk(args, True)


def configureSplunk(args, splunk_enable):

    if not args.splunk_endpoint:
        args.splunk_endpoint = raw_input("Please enter the Splunk Endpoint: ")

    if not args.splunk_token:
        args.splunk_token = raw_input("Please enter the Splunk Token: ")

    if not args.splunk_index:
        args.splunk_index = raw_input("Please enter the Splunk Index: ")

    if not args.scm_repo:
        args.scm_repo = raw_input("Please enter the SCM Repo: ")

    if not args.scm_username:
        args.scm_username = raw_input("Please enter the SCM Username: ")

    if not args.scm_password:
        args.scm_password = raw_input("Please enter the SCM Password: ")

    if not args.scm_pathext:
        args.scm_pathext = raw_input("Please enter the Splunk Pathext (Use \"/scm\" for bitbucket): ") or "/"

    if not args.splunk_endpoint and not args.splunk_token and not args.splunk_index:
        print(colors.FAIL +
              'Cannot proceed! No install possible'
              + colors.ENDC)
        return True

    replace_config(args)


def replace_config(args):

    # Clone the SCM
    subprocess.check_call(
        [
            "git",
            "clone",
            ("http://%s:%s@%s%s/slf/jazz-build-module.git") %
            (args.scm_username,
             urllib.quote(
                 args.scm_password),
             args.scm_repo,
             args.scm_pathext),
            "--depth",
            "1"])

    configFile = "jazz-installer-vars.json"
    buildFolder = './jazz-build-module/'
    # Read in the file
    with open(buildFolder+configFile, 'r') as file:
        filedata = file.read()

    # Replace the target string
    filedata = filedata.replace('"{ENABLE_SPLUNK_FEATURE}"', 'true')
    filedata = filedata.replace('{SPLUNK_ENDPOINT}', args.splunk_endpoint)
    filedata = filedata.replace('{SPLUNK_TOKEN}', args.splunk_token)
    filedata = filedata.replace('{SPLUNK_INDEX}', args.splunk_index)

    # Write the file out again
    with open(buildFolder+configFile, 'w') as file:
        file.write(filedata)

    # Commit the changes
    subprocess.check_call(["git", "add", configFile], cwd=buildFolder)
    subprocess.check_call(["git", "commit", "-m", "'Adding Splunk feature'"], cwd=buildFolder)
    subprocess.check_call(["git", "push", "-u", "origin", "master"], cwd=buildFolder)
    subprocess.check_call(["rm", "-rf", buildFolder])


main()
