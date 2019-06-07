import os
from pathlib import Path
import re
import secrets
import datetime
import string
import boto3
import in_place
import uuid
from installer.configurators.validate_tags import prepare_tags, validate_replication_tags


# TODO revisit the use of an env var here, only the destroy script uses it, and it probably shouldn't
def get_installer_root():
    # Set the repo root path as an env var here,
    # so subsequent scripts don't need to hardcode absolute paths.
    return os.environ.get('JAZZ_INSTALLER_ROOT', str(Path('.').absolute()))


def get_terraform_folder():
    return get_installer_root() + "/installer/terraform/"


def get_tfvars_file():
    return get_terraform_folder() + "terraform.tfvars"


def passwd_generator():
    """
        Random password generator for jazz_ui admin email ID login
    """
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for i in range(8))


def get_account_id():
    return boto3.client('sts').get_caller_identity().get('Account')


def update_main_terraform_vars(branch, adminemail, stackprefix, region, tags):
    """
        Method parse the parameters send from run.py and these common variables
        are set in terraform.tfvars and other files needed
    """
    jazz_branch = branch
    cognito_details = [adminemail, passwd_generator()]
    jazz_account_id = get_account_id()
    prefix = stackprefix.lower()
    tag_exempt = (datetime.datetime.today() +
                  datetime.timedelta(days=1)).strftime("%m/%d/%Y")

    # ----------------------------------------------------------
    # Populate Terraform variables in terraform.tfvars
    # -----------------------------------------------------------

    # populating BRANCH name
    replace_tfvars('github_branch', jazz_branch, get_tfvars_file())

    # populating region
    replace_tfvars('region', region, get_tfvars_file())
    os.environ['AWS_DEFAULT_REGION'] = region

    # Populating Jazz Account ID
    replace_tfvars('jazz_accountid', jazz_account_id, get_tfvars_file())

    # Populating Cognito Details
    replace_tfvars('cognito_pool_username', cognito_details[0],
                   get_tfvars_file())
    replace_tfvars('cognito_pool_password', cognito_details[1],
                   get_tfvars_file())

    # Generate ACL DB password
    replace_tfvars('acl_db_password', uuid.uuid4().hex,
                   get_tfvars_file())

    # Set the default values of scm_username/passwd to the cognito credentials
    # If using existing SCM instance, that scenario (e.g. 1) will obviously overwrite these values.
    # For some reason Gitlab needs the username to conform to this specific regex
    replace_tfvars('scm_username', re.sub('[^a-zA-Z0-9_-]', '-', cognito_details[0]), get_tfvars_file())
    replace_tfvars('scm_passwd', cognito_details[1], get_tfvars_file())

    # Populating Jazz Tag env
    replace_tfvars('envPrefix', prefix, get_tfvars_file())
    replace_tfvars('tagsExempt', tag_exempt, get_tfvars_file())

    # Populating user tags
    if tags:
        input_tags = prepare_tags(tags)
        try:
            aws_tags, aws_formatted_tags = validate_replication_tags(input_tags)
            replace_tfvars("aws_tags", str(aws_tags), get_tfvars_file())
            replace_tfvars("additional_tags", str(aws_formatted_tags), get_tfvars_file(), quoteVal=False)
        except ValueError as err:
            print("Invalid Tag!" + str(err))
            exit(0)


# Modify the values of key-value pairs within a file
# (such as a .tfvars file) that follow the form 'key = value'
# If the value exists in a map (and needs the quotes left off)
# use quoteVal=False
def replace_tfvars(key, value, fileName, quoteVal=True):
    with in_place.InPlace(fileName) as fileContent:
        for line in fileContent:
            if quoteVal:
                fileContent.write(re.sub(r'({0} = )(.*)'.format(key), r'\1"{0}"'.format(value), line))
            else:
                fileContent.write(re.sub(r'({0} = )(.*)'.format(key), r'\1{0}'.format(value), line))


def validate_email_id(email_id):
    """
        Parse the parameters send from run.py and validate Cognito details
    """
    if re.search(r'[^@]+@[^@]+.[^@]+', email_id) is None:
        return False
    else:
        return True
