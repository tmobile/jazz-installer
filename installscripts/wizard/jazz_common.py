#!/usr/bin/python
import os
import re
import subprocess

#Global variables
TFVARS_FILE = "terraform.tfvars"
HOME_JAZZ_INSTALLER = os.path.expanduser("~") + "/jazz-installer/"
COGNITO_USER_FILE = HOME_JAZZ_INSTALLER + "/installscripts/cookbooks/jenkins/files/credentials/cognitouser.sh"
DEFAULT_RB = HOME_JAZZ_INSTALLER + "/installscripts/cookbooks/jenkins/attributes/default.rb"

def parse_and_replace_paramter_list(terraform_folder, parameter_list):
    """
        Method parse the parameters send from run.py and these common variables
        are replaced in variables.tf and other files needed
    """
    jazz_branch = parameter_list[0]
    cognito_details = parameter_list[1]
    jazz_account_id = parameter_list[2]
    jazz_tag_details = parameter_list[3] #[tag_env_prefix, tag_enviornment, tag_exempt, tag_owner]

    os.chdir(terraform_folder)

    # ----------------------------------------------------------
    # Populate variables in terraform variables.tf and cookbooks
    # -----------------------------------------------------------

    #populating BRANCH name
    replace_tfvars('github_branch', jazz_branch, TFVARS_FILE)
    subprocess.call(['sed', '-i', "s|default\['git_branch'\].*.|default\['git_branch'\]='%s'|g" %(jazz_branch), DEFAULT_RB])

    # Populating Jazz Account ID
    replace_tfvars('jazz_accountid', jazz_account_id, TFVARS_FILE)

    # Populating Cognito Details
    replace_tfvars('cognito_pool_username', cognito_details[0], TFVARS_FILE)
    replace_tfvars('cognito_pool_password', cognito_details[1], TFVARS_FILE)
    subprocess.call(['sed', '-i', "s|<username>cognitouser</username>|<username>%s</username>|g" %(cognito_details[0]), COGNITO_USER_FILE])
    subprocess.call(['sed', '-i', "s|<password>cognitopasswd</password>|<password>%s</password>|g" %(cognito_details[1]), COGNITO_USER_FILE])

    # Populating Jazz Tag env
    replace_tfvars('envPrefix', jazz_tag_details[0], TFVARS_FILE)
    replace_tfvars('tagsEnvironment', jazz_tag_details[1], TFVARS_FILE)
    replace_tfvars('tagsExempt', jazz_tag_details[2], TFVARS_FILE)
    replace_tfvars('tagsOwner', jazz_tag_details[3], TFVARS_FILE)
    subprocess.call(['sed', '-i', 's|stack_name=.*.$|stack_name="%s"|g' %(jazz_tag_details[0]), "scripts/destroy.sh"])

# Uses sed to modify the values of key-value pairs within a file that follow the form 'key = value'
# NOTE: The use of "-i'.bak'" and the creation of backup files is required macOS (that is, BSD) 'sed' will fail otherise.
def replace_tfvars(key, value, fileName):
    subprocess.call(['sed', '-i\'.bak\'', "s|\(%s = \)\(.*\)|\1\"%s\"|g" %(key, value), fileName])

def validate_email_id(email_id):
    """
        Method parse the parameters send from run.py and validate Cognito details
    """
    if re.search('[^@]+@[^@]+\.[^@]+', email_id) is None:
        return False
    else:
        return True
