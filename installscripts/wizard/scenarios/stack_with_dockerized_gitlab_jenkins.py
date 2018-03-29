#!/usr/bin/python
import os
import sys
import subprocess
from support.jazz_common import INSTALL_SCRIPT_FOLDER, TERRAFORM_FOLDER_PATH, parse_and_replace_parameter_list
from support.jazz_jenkins import get_and_add_docker_jenkins_config
from support.jazz_gitlab import get_and_add_docker_gitlab_config

# Global variables
JENKINS_DOCKER_PATH = INSTALL_SCRIPT_FOLDER + "dockerfiles/jenkins/"
GITLAB_DOCKER_PATH = INSTALL_SCRIPT_FOLDER + "dockerfiles/gitlab/"
JENKINS_PEM = JENKINS_DOCKER_PATH + "/jenkinskey.pem"


def check_jenkins_pem():
    """
        Check if the user has provided jenkinskey.pem private keys
    """
    # Check if both files are been added to home derectory
    if not os.path.isfile(JENKINS_PEM):
        sys.exit(
            "File jenkinskey.pem is not present in your home (~/) folder, kindly add and run the installer again! "
        )

    # Copy the pem keys and give relavant permissions to a dockerkeys location. This is different from Scenario 1.
    subprocess.call('cp -f {0} {1}sshkeys/dockerkeys'.format(
        JENKINS_PEM, INSTALL_SCRIPT_FOLDER).split(' '))
    subprocess.call(
        'sudo chmod 400 {0}sshkeys/dockerkeys/jenkinskey.pem'.format(
            INSTALL_SCRIPT_FOLDER).split(' '))


def start(parameter_list):
    """
        start stack creation
    """
    parse_and_replace_parameter_list(TERRAFORM_FOLDER_PATH, parameter_list)
    print("Deploying Dockerized Jenkins server==============>")
    get_and_add_docker_jenkins_config(JENKINS_DOCKER_PATH)
    check_jenkins_pem()

    # Deploy Gitlab docker and get configuration details
    print("Deploying Dockerized Gitlab server==============>")
    get_and_add_docker_gitlab_config(GITLAB_DOCKER_PATH)

    # All variables are set and ready to call terraform
    os.chdir(TERRAFORM_FOLDER_PATH)

    print("Invoking Terraform==============================>")
    subprocess.call(
        'nohup ./scripts/create.sh | tee ../../stack_creation.out&',
        shell=True)
    print("Copying Terraform destroy script================>")
    subprocess.call('cp ./scripts/destroy.sh ../../'.split(' '))

    print(
        "\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory to see the stack creation progress "
    )
    print(os.path.realpath('../../'))
    print("\n\n")
