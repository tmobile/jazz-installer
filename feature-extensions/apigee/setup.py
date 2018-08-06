#!/usr/bin/env python2
import subprocess
import argparse
import os.path


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


featureName = "Apigee"


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "-i",
        "--install",
        help="Install {0} feature extension".format(featureName),
        action="store_true")
    group.add_argument(
        "-u",
        "--uninstall",
        help="Uninstall {0} feature extension".format(featureName),
        action="store_true")
    args = parser.parse_args()

    if args.install:
        install()

    if args.uninstall:
        uninstall()


def install():
    print(
        colors.OKGREEN +
        "\nThis will install {0} functionality into your Jazz deployment.\n".format(featureName)
        + colors.ENDC)
    print(
        colors.OKGREEN +
        "This installer will use whatever AWS credentials you have configured by running 'aws configure'.\n"
        + colors.ENDC)
    print(
        colors.WARNING +
        "Please make sure you are using the same AWS credentials you used to install your Jazz deployment\n\n"
        + colors.ENDC)
    runTerraform(getRegion(), getAWSAccountID(), getEnvPrefix(), True)


def uninstall():
    print(
        colors.OKGREEN +
        "\nThis will remove {0} functionality from your Jazz deployment.\n".format(featureName)
        + colors.ENDC)

    terraformStateSanityCheck()
    runTerraform(getRegion(), getAWSAccountID(), getEnvPrefix(), False)


def runTerraform(region, accountId, envPrefix, install):
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='./terraform')

    subprocess.check_call(
        [
            'terraform', 'apply' if install else 'destroy', '-auto-approve',
            '-var', 'region={0}'.format(region),
            '-var', 'jazz_aws_accountid={0}'.format(accountId),
            '-var', 'env_prefix={0}'.format(envPrefix)
        ],
        cwd='./terraform')


def terraformStateSanityCheck():
    print(colors.OKBLUE +
          'Making sure you have not deleted the Terraform .tfstate file...' +
          colors.ENDC)
    if not os.path.isfile('./terraform/terraform.tfstate'):
        print(colors.FAIL +
              'Cannot find the Terraform .tfstate file! No uninstall possible'
              + colors.ENDC)


def getRegion():
    region = raw_input(
        "Please enter the region where your Jazz installation lives: ")

    if region is "":
        print("No region entered, defaulting to 'us-east-1'")
        region = "us-east-1"
    return region


# TODO Obviously it would be better if we could somehow automatically infer the
# env prefix that the user used to install Jazz proper, but I don't see a
# robust way to do that yet, so KISS is a better principal to follow here.
# Also, there are no programmatic side effects if they happen to enter a
# different prefix.
def getEnvPrefix():
    return raw_input(
        "Please enter the environment prefix you used for your Jazz install: ")


def getAWSAccountID():
    print(colors.OKBLUE +
          'Obtaining AWS account ID using configured credentials\n' +
          colors.ENDC)
    return subprocess.check_output([
        'aws', 'sts', 'get-caller-identity', '--output', 'text', '--query', 'Account'
    ]).rstrip()


main()
