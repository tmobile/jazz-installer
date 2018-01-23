#!/usr/bin/python
import os
import re
import subprocess

#Global variables
VARIABLES_TF_FILE = "variables.tf"
ENVPREFIX_TF_FILE = "envprefix.tf"
HOME_JAZZ_INSTALLER = os.path.expanduser("~") + "/jazz-installer/"
COGNITO_USER_FILE = HOME_JAZZ_INSTALLER + "/installscripts/cookbooks/jenkins/files/credentials/cognitouser.sh"
DEFAULT_RB = HOME_JAZZ_INSTALLER + "/installscripts/cookbooks/jenkins/attributes/default.rb"

def parse_and_replace_paramter_list(terraform_folder, parameter_list):
    """
        Method parse the parameters send from run.py and these common variables
        are replaced in variables.tf and other files needed
    """
    jazz_branch = parameter_list[0]
    aws_credentials = parameter_list[1]
    aws_region = parameter_list[2]
    cognito_details = parameter_list[3]
    jazz_account_id = parameter_list[4]
    jazz_tag_details = parameter_list[5] #[tag_env_prefix, tag_enviornment, tag_exempt, tag_owner]

    os.chdir(terraform_folder)

    # ----------------------------------------------------------
    # Populate variables in terraform variables.tf and cookbooks
    # -----------------------------------------------------------
    # Populating AWS Accesskey and
    subprocess.call(['sed', '-i', "s|variable \"aws_access_key\".*.$|variable \"aws_access_key\" \{ type = \"string\" default = \"%s\" \}|g" %(aws_credentials[0]), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|variable \"aws_secret_key\".*.$|variable \"aws_secret_key\" \{ type = \"string\" default = \"%s\" \}|g" %(aws_credentials[1]), VARIABLES_TF_FILE])

    # Populating AWS Region
    subprocess.call(['sed', '-i', "s|variable \"region\".*.$|variable \"region\" \{ type = \"string\" default = \"%s\" \}|g" %(aws_region), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|variable \"github_branch\".*.$|variable \"github_branch\" \{ type = \"string\" default = \"%s\" \}|g" %(jazz_branch), VARIABLES_TF_FILE])

    #populating BRANCH name
    subprocess.call(['sed', '-i', "s|variable \"github_branch\".*.$|variable \"github_branch\" \{ type = \"string\" default = \"%s\" \}|g" %(jazz_branch), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|default\['git_branch'\].*.|default\['git_branch'\]='%s'|g" %(jazz_branch), DEFAULT_RB])

    # Populating Jazz Account ID
    subprocess.call(['sed', '-i', "s|variable \"jazz_accountid\".*.$|variable \"jazz_accountid\" \{ type = \"string\" default = \"%s\" \}|g" %(jazz_account_id), VARIABLES_TF_FILE])

    # Populating Cognito Details
    subprocess.call(['sed', '-i', "s|default = \"cognito_pool_username\"|default = \"%s\"|g" %(cognito_details[0]), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|default = \"cognito_pool_password\"|default = \"%s\"|g" %(cognito_details[1]), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|<username>cognitouser</username>|<username>%s</username>|g" %(cognito_details[0]), COGNITO_USER_FILE])
    subprocess.call(['sed', '-i', "s|<password>cognitopasswd</password>|<password>%s</password>|g" %(cognito_details[1]), COGNITO_USER_FILE])

    # Populating Jazz Tag env
    subprocess.call(['sed', '-i', "s|variable \"envPrefix\".*.$|variable \"envPrefix\" \{ type = \"string\"  default = \"%s\" \}|g" %(jazz_tag_details[0]), ENVPREFIX_TF_FILE])
    subprocess.call(['sed', '-i', "s|variable \"tagsEnvironment\".*.$|variable \"tagsEnvironment\" \{type = \"string\" default = \"%s\" \}|g" %(jazz_tag_details[1]), ENVPREFIX_TF_FILE])
    subprocess.call(['sed', '-i', "s|variable \"tagsExempt\".*.$|variable \"tagsExempt\" \{ type = \"string\" default = \"%s\" \}|g" %(jazz_tag_details[2]), ENVPREFIX_TF_FILE])
    subprocess.call(['sed', '-i', "s|variable \"tagsOwner\".*.$|variable \"tagsOwner\" \{ type = \"string\" default = \"%s\" \}|g" %(jazz_tag_details[3]), ENVPREFIX_TF_FILE])
    subprocess.call(['sed', '-i', 's|stack_name=.*.$|stack_name="%s"|g' %(jazz_tag_details[0]), "scripts/destroy.sh"])

def validate_email_id(email_id):
    """
        Method parse the parameters send from run.py and validate Cognito details
    """
    if re.search('[^@]+@[^@]+\.[^@]+', email_id) is None:
        return False
    else:
        return True
