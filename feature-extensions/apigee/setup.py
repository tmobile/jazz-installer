#!/usr/bin/env python2
import subprocess


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def main():
    print("WHOOP")
    print(colors.OKGREEN +
            "\nThis will install Apigee functionality into your Jazz deployment.\n"
            + colors.ENDC)
    print(colors.OKGREEN +
            "This installer will use whatever AWS credentials you have configured by running 'aws configure'.\n"
            + colors.ENDC)
    print(colors.WARNING +
            "Please make sure you are using the same AWS credentials you used to install your Jazz deployment\n\n"
            + colors.ENDC)
    awsRegion = getRegion()
    awsAccountId = getAWSAccountID()
    runTerraform(awsRegion, awsAccountId)


def runTerraform(region, accountId):
    print(colors.OKBLUE +
            'Initializing and running Terraform.\n'
            + colors.ENDC)
    subprocess.check_call([
        'terraform',
        'init'
    ], cwd='./terraform')

    subprocess.check_call([
        'terraform',
        'apply',
        '-auto-approve',
        '-var',
        'region={0}'.format(region),
        '-var',
        'jazz_aws_accountid={0}'.format(accountId)
    ], cwd='./terraform')


def getRegion():
    region = raw_input("Please enter the region where your Jazz installation lives: ")

    if region is "":
        print("No region entered, defaulting to 'us-east-1'")
        region = "us-east-1"
    return region


def getAWSAccountID():
    print(colors.OKBLUE +
            'Obtaining AWS account ID using configured credentials\n'
            + colors.ENDC)
    return subprocess.check_output([
        'aws',
        'sts',
        'get-caller-identity',
        '--output',
        'text',
        '--query',
        'Account']).rstrip()


main()
