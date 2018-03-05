#!/usr/bin/python
import os
import sys
import random
import string
import subprocess
import datetime
import config
from jazz_common import validate_email_id

#Global Variables
DEV_NULL = open(os.devnull, 'w')

def passwd_generator():
    """
        Random password generator for jazz-ui admin email ID login
    """
    length = 10
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
        Get the aws credentials from user
    """
    aws_access_key = raw_input("AWS Access Key ID :")
    aws_secret_key = raw_input("AWS Secret Access Key :")
    return [aws_access_key, aws_secret_key]

def write_aws_credential_to_file(aws_access_key, aws_secret_key):
    """
        Writing the aws credential ~/aws/credentials file
    """
    home = os.path.expanduser("~")
    aws_folder = home + "/.aws"
    aws_credential_file = aws_folder + "/credentials"

    if not os.path.isdir(aws_folder):
        os.makedirs(aws_folder)

    #write to the file
    fd = open(aws_credential_file, "w")
    fd.write("[default]\n")
    fd.write("aws_access_key_id = " + aws_access_key + "\n")
    fd.write("aws_secret_access_key = " + aws_secret_key + "\n")

def write_aws_config_to_file(region):
    """
        Writing the aws credential ~/aws/config file
    """
    home = os.path.expanduser("~")
    aws_folder = home + "/.aws"
    aws_config_file = aws_folder + "/config"

    #write to the file
    fd = open(aws_config_file, "w")
    fd.write("[default]\n")
    fd.write("output = json\n")
    fd.write("region = " + region + "\n")

def get_jazz_tag_config_details():
    """
        Get tag configuration details from user and add it to the files
    """
        #Get the Tag Name from the user - Should not exceed 13 character. It may break the S3 bucket creation
    tag_env_prefix = raw_input("Please provide a prefix for your stack (limited to 13 characters)(eg: myjazz) :")
    while(len(tag_env_prefix) > 13 or len(tag_env_prefix) == 0):
            tag_env_prefix = raw_input("Please provide a prefix for your stack (limited to 13 characters)(eg: myjazz) :")
    tag_env_prefix = tag_env_prefix.lower()

    #TODO - Need to check if we really need this
    tag_enviornment="Development"
    tag_exempt=(datetime.datetime.today()+datetime.timedelta(days=1)).strftime("%m/%d/%Y")
    tag_owner=tag_env_prefix+"-Admin"

    return [tag_env_prefix, tag_enviornment, tag_exempt, tag_owner]

def get_stack_generic_details(jazz_branch):

    print ""
    print("Please provide the details to setup Jazz")

    region = None

    while True:
        region = raw_input("AWS Region (us-east-1 or us-west-2): ")
        if region == 'us-east-1':
            print 'Valid region'
            break
        elif region == 'us-west-2':
            print 'valid region'
            break
        else:
            print 'Invalid region, please try again..'

    # Get the aws credentials
    aws_credentials = get_aws_credentials()
    while aws_credentials[0] == '' or aws_credentials[1] == '':
        print "Please provide the AWS credentials"
        aws_credentials = get_aws_credentials()

    write_aws_credential_to_file(aws_credentials[0], aws_credentials[1])
    write_aws_config_to_file(region)

    # get Jazz Tag details
    jazz_tag_details = get_jazz_tag_config_details()

    # Get Cognito details
    while(1):
        cognito_email_id = raw_input("Please provide admin email address (will be used to login into Jazz):")
        if validate_email_id(cognito_email_id):
            break
        else:
            print "The email address is invalid."
    cognito_passwd = passwd_generator()

    jazz_account_id = ""
    try:
        jazz_accountid_cmd = ['/usr/local/bin/aws', 'sts', 'get-caller-identity', '--output', 'text', '--query',
                              'Account']
        jazz_account_id = subprocess.check_output(jazz_accountid_cmd)

    except:
        print "Unable to get caller identity. Are you sure the credentials are correct? Please retry..."
        exit(0)
    jazz_account_id = jazz_account_id[:-1]

    # Determine the scenario
    parameter_list = [jazz_branch, aws_credentials, region, [cognito_email_id, cognito_passwd], jazz_account_id, jazz_tag_details, config.settings['jazz_install_dir']]

    return parameter_list
