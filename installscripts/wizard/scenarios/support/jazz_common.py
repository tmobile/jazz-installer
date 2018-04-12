#!/usr/bin/python
import os
import re
import subprocess

# Global variables
HOME_FOLDER = "~"


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


def parse_and_replace_parameter_list(terraform_folder, parameter_list):
    """
        Method parse the parameters send from run.py and these common variables
        are set in terraform.tfvars and other files needed
    """
    jazz_branch = parameter_list[0]
    cognito_details = parameter_list[1]
    jazz_account_id = parameter_list[2]
    jazz_tag_details = parameter_list[3]
    # [tag_env_prefix, tag_enviornment, tag_exempt, tag_owner]

    os.chdir(terraform_folder)

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
    replace_tfvars('envPrefix', jazz_tag_details[0], get_tfvars_file())
    replace_tfvars('tagsEnvironment', jazz_tag_details[1], get_tfvars_file())
    replace_tfvars('tagsExempt', jazz_tag_details[2], get_tfvars_file())
    replace_tfvars('tagsOwner', jazz_tag_details[3], get_tfvars_file())

    # TODO look into why we need a script to tear down AWS resources,
    # my understanding is that Terraform should be able to delete everything
    # it creates, by definition.
    subprocess.call([
        'sed', '-i',
        's|stack_name=.*.$|stack_name="%s"|g' % (jazz_tag_details[0]),
        "scripts/destroy.sh"
    ])


# Uses sed to modify the values of key-value pairs within a file
# (such as a .tfvars file) that follow the form 'key = value'
# NOTE: The use of "-i'.bak'" and the creation of backup files is required,
# macOS (that is, BSD) 'sed' will fail otherise.


# NOTE: The `r` prefix is needed to force a string literal here.
# TODO: We should replace `sed` executable calls with standard python library
# calls, would be faster and simpler.
def replace_tfvars(key, value, fileName):
    subprocess.call([
        'sed', "-i\'.bak\'",
        r's|\(%s = \)\(.*\)|\1\"%s\"|g' % (key, value), fileName
    ])


def validate_email_id(email_id):
    """
        Parse the parameters send from run.py and validate Cognito details
    """
    if re.search('[^@]+@[^@]+\.[^@]+', email_id) is None:
        return False
    else:
        return True
