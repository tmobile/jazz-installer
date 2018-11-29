import os
import re
import secrets
import datetime
import string
import boto3
import in_place
from installer.configurators.validate_tags import prepare_tags, validate_replication_tags


# TODO revisit the use of an env var here
def get_installer_root():
    return os.environ['JAZZ_INSTALLER_ROOT']


def get_script_folder():
    return get_installer_root() + "/installscripts/"


def get_terraform_folder():
    return get_script_folder() + "/jazz-terraform-unix-noinstances/"


def get_tfvars_file():
    return get_terraform_folder() + "terraform.tfvars"


def get_docker_path():
    return get_script_folder() + "dockerfiles/"


def get_jenkins_pem():
    return get_docker_path() + "jenkins/jenkinskey.pem"


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
    # Populate Terraform variables in terraform.tfvars and Chef cookbook
    # -----------------------------------------------------------

    # populating BRANCH name
    replace_tfvars('github_branch', jazz_branch, get_tfvars_file())

    # Populating Jazz Account ID
    replace_tfvars('jazz_accountid', jazz_account_id, get_tfvars_file())

    # Populating Cognito Details
    replace_tfvars('cognito_pool_username', cognito_details[0],
                   get_tfvars_file())
    replace_tfvars('cognito_pool_password', cognito_details[1],
                   get_tfvars_file())

    # Populating Jazz Tag env
    replace_tfvars('envPrefix', prefix, get_tfvars_file())
    replace_tfvars('tagsExempt', tag_exempt, get_tfvars_file())

    # Populating user tags
    if tags:
        input_tags = prepare_tags(tags)
        try:
            aws_tags, aws_formatted_tags = validate_replication_tags(input_tags)
            replace_tfvars("aws_tags", str(aws_tags), get_tfvars_file())
            replace_tfvars("additional_tags", str(aws_tags), get_tfvars_file(), quoteVal=False)
        except ValueError as err:
            print("Invalid Tag!" + str(err))
            exit(0)

    # TODO replace this with `terraform output` and drop sed
    # subprocess.call([
    #     'sed', '-i',
    #     's|stack_name=.*.$|stack_name="%s"|g' % (prefix),
    #     "scripts/destroy.sh"
    # ])


# Uses sed to modify the values of key-value pairs within a file
# (such as a .tfvars file) that follow the form 'key = value'

def replace_tfvars(key, value, fileName, quoteVal=True):
    with in_place.InPlace(fileName) as fileContent:
        for line in fileContent:
            if quoteVal:
                fileContent.write(re.sub(r'({0} = )(.*)'.format(key), r'\1"{0}"'.format(value), line))
            else:
                fileContent.write(re.sub(r'({0} = )(.*)'.format(key), r'\1{0}'.format(value), line))


# def replace_tfvars(key, value, fileName):
#     subprocess.call([
#         'sed', "-i\'.bak\'",
#         r's|\(%s = \)\(.*\)|\1\"%s\"|g' % (key, value), fileName
#     ])

# replace it without double quotes
# def replace_tfvars_map(key, value, fileName):
#     subprocess.call([
#         'sed', "-i\'.bak\'",
#         r's|\(%s = \)\(.*\)|\1%s|g' % (key, value), fileName
#     ])


def validate_email_id(email_id):
    """
        Parse the parameters send from run.py and validate Cognito details
    """
    if re.search('[^@]+@[^@]+\.[^@]+', email_id) is None:
        return False
    else:
        return True
