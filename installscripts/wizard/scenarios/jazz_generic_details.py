#!/usr/bin/python
import os
import random
import string
import subprocess
import datetime
from support.jazz_common import validate_email_id


def passwd_generator():
    """
        Random password generator for jazz_ui admin email ID login
    """
    pwd = []
    pwd.append(random.choice(string.ascii_lowercase))
    pwd.append(random.choice(string.ascii_uppercase))
    pwd.append(random.choice(string.digits))
    pwd.append("@")
    for x in range(6):
        pwd.append(random.choice(string.letters))

    random.shuffle(pwd)
    return ''.join(pwd)


def get_aws_credentials():
    """
        There's a strong argument to be made that we should drop all this
        and ask users to configure their AWS credentials on their own,
        and simply error out if they aren't configured.

        If the AWS credentials have not already been defined as env vars,
        populate those env vars and update the user's AWSCLI config

        If credentials WERE set thru env vars, just use those values and don't
        clobber the user's AWSCLI config.
    """
    if "AWS_ACCESS_KEY_ID" and "AWS_SECRET_ACCESS_KEY" not in os.environ:
        os.environ['AWS_ACCESS_KEY_ID'] = raw_input("AWS Access Key ID :")
        os.environ['AWS_SECRET_ACCESS_KEY'] = raw_input(
            "AWS Secret Access Key :")
        subprocess.call(['aws', 'configure', 'set', 'aws_access_key_id', os.environ['AWS_ACCESS_KEY_ID']])
        subprocess.call(['aws', 'configure', 'set', 'aws_secret_access_key', os.environ['AWS_SECRET_ACCESS_KEY']])
    else:
        print("Found default AWS credentials in 'AWS_ACCESS_KEY_ID' and 'AWS_SECRET_ACCESS_KEY' env vars, using those...")


def get_region():
    region = None
    knownWorkingRegions = ['us-east-1', 'us-west-2']

    region = raw_input("AWS Region (e.g. us-east-1): ")

    if region is "":
        print("No region entered, defaulting to 'us-east-1'")
        region = "us-east-1"

    if region not in knownWorkingRegions:
        print(
            'Warning: This installer has not been tested against the region you specified.\nPlease check the Jazz documentation (https://github.com/tmobile/jazz-installer/wiki#prerequisites) to verify the region you have chosen supports the required AWS resources.\n\n'
        )
        raw_input('Press Enter to continue anyway, or Control+C to abort...')

    os.environ['AWS_DEFAULT_REGION'] = region


def get_jazz_tag_config_details():
    """
        Get tag configuration details from user and add it to the files
    """
    # Get the Tag Name from the user - Should not exceed 13 character. It may break the S3 bucket creation
    tag_env_prefix = raw_input(
        "Please provide a prefix for your stack (limited to 13 characters)(eg: myjazz) :"
    )
    while (len(tag_env_prefix) > 13 or len(tag_env_prefix) == 0):
        tag_env_prefix = raw_input(
            "Please provide a prefix for your stack (limited to 13 characters)(eg: myjazz) :"
        )

    tag_env_prefix = tag_env_prefix.lower()

    # TODO Since most of these are currently static we could define them with interpolation in envprefix.tf
    tag_environment = "Development"
    tag_exempt = (datetime.datetime.today() +
                  datetime.timedelta(days=1)).strftime("%m/%d/%Y")
    tag_owner = tag_env_prefix + "-Admin"

    return [tag_env_prefix, tag_environment, tag_exempt, tag_owner]


def get_stack_generic_details(jazz_branch):
    print("")
    print("Please provide the details to setup Jazz")

    # Get the aws credentials & set required AWS env vars
    get_region()
    get_aws_credentials()

    # Not sure we need this..
    os.environ['AWS_DEFAULT_OUTPUT'] = 'json'

    # get Jazz Tag details
    jazz_tag_details = get_jazz_tag_config_details()

    # Get Cognito details
    while (1):
        cognito_email_id = raw_input(
            "Please provide admin email address (will be used to login into Jazz):"
        ).lower()
        if validate_email_id(cognito_email_id):
            break
        else:
            print("The email address is invalid.")

    cognito_passwd = passwd_generator()
    jazz_account_id = ""

    try:
        jazz_accountid_cmd = [
            'aws', 'sts', 'get-caller-identity', '--output', 'text', '--query',
            'Account'
        ]
        jazz_account_id = subprocess.check_output(jazz_accountid_cmd)

    except:
        print(
            "Unable to get caller identity. Are you sure the credentials are correct? Please retry..."
        )
        exit(0)

    jazz_account_id = jazz_account_id[:-1]

    # Determine the scenario
    parameter_list = [
        jazz_branch, [cognito_email_id, cognito_passwd], jazz_account_id,
        jazz_tag_details
    ]

    return parameter_list
