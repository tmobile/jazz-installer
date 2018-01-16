#!/usr/bin/python
import os
import sys
import subprocess
from jazz_common import parse_and_replace_paramter_list
from jazz_jenkins import get_and_add_docker_jenkins_config
from jazz_gitlab import get_and_add_docker_gitlab_config

# Global variables
HOME_FOLDER = os.path.expanduser("~")
HOME_JAZZ_INSTALLER = HOME_FOLDER + "/jazz-installer/"
HOME_INSTALL_SCRIPTS = HOME_JAZZ_INSTALLER + "installscripts/"
JENKINS_DOCKER_PATH = HOME_INSTALL_SCRIPTS + "dockerfiles/jenkins/"
GITLAB_DOCKER_PATH = HOME_INSTALL_SCRIPTS + "dockerfiles/gitlab/"
TERRAFORM_FOLDER_PATH = HOME_INSTALL_SCRIPTS + "jazz-terraform-unix-noinstances"
VARIABLES_TF_FILE = TERRAFORM_FOLDER_PATH + "variables.tf"
JENKINS_PEM = HOME_FOLDER + "/jenkinskey.pem"

def check_jenkins_pem():
    """
        Check if the user has provided jenkinskey.pem private keys
    """
    #Chck if both files are been added to home derectory
    if not os.path.isfile(JENKINS_PEM):
        sys.exit("File jenkinskey.pem is not present in your home (~/) folder, kindly add and run the installer again! ")

    #Copy the pem keys and give relavant permisions
    subprocess.call('cp -f {0} {1}sshkeys'.format(JENKINS_PEM, HOME_INSTALL_SCRIPTS).split(' '))
    subprocess.call('sudo chmod 400 {0}sshkeys/jenkinskey.pem'.format(HOME_INSTALL_SCRIPTS).split(' '))

def start(parameter_list):
    """
        start stack creation
    """
    parse_and_replace_paramter_list(TERRAFORM_FOLDER_PATH, parameter_list)
    print("Deploying Dockerized Jenkins server==============>")
    get_and_add_docker_jenkins_config(JENKINS_DOCKER_PATH)
    check_jenkins_pem()

    # Deploy Gitlab docker and get configuration details
    print("Deploying Dockerized Gitlab server==============>")
    get_and_add_docker_gitlab_config(GITLAB_DOCKER_PATH)

    #All variables are set and ready to call terraform
    os.chdir(TERRAFORM_FOLDER_PATH)

    subprocess.call('nohup ./scripts/create.sh >>../../stack_creation.out&',shell=True)
    subprocess.call('cp ./scripts/destroy.sh ../../'.split(' '))

    print("\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory to see the stack creation progress ")
    print(os.path.realpath('../../'))
    print("\n\n")
