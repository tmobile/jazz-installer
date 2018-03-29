#!/usr/bin/python
import os
import sys
import subprocess
from jazz_common import parse_and_replace_parameter_list, INSTALL_SCRIPT_FOLDER, TERRAFORM_FOLDER_PATH, HOME_FOLDER
from jazz_jenkins import get_and_add_docker_jenkins_config
from jazz_bitbucket import get_and_add_existing_bitbucket_config

#Global variables
JENKINS_DOCKER_PATH = INSTALL_SCRIPT_FOLDER + "dockerfiles/jenkins/"
JENKINS_PEM = JENKINS_DOCKER_PATH + "/jenkinskey.pem"

def pause():
    programPause = raw_input("Press the <ENTER> key to continue...")

def check_dockerised_jenkins_pem():
    """
        Check if the jenkins dockerised has created jenkinskey.pem private keys
    """
    #Chck if both files are been added to home derectory
    if not os.path.isfile(JENKINS_PEM):
        sys.exit("File jenkinskey.pem missing. Aborting! ")

    #Copy the pem keys and give relavant permissions to a dockerkeys location. This is different from Scenario 1.
    subprocess.call('cp -f {0} {1}sshkeys/dockerkeys'.format(JENKINS_PEM, INSTALL_SCRIPT_FOLDER).split(' '))
    subprocess.call('sudo chmod 400 {0}sshkeys/dockerkeys/jenkinskey.pem'.format(INSTALL_SCRIPT_FOLDER).split(' '))

def start(parameter_list):
    """
        start stack creation
    """
    parse_and_replace_parameter_list(TERRAFORM_FOLDER_PATH, parameter_list)

    # Get Bitbucket configuration details
    get_and_add_existing_bitbucket_config(TERRAFORM_FOLDER_PATH)

    # Launch the Jenkins Docker
    print("Deploying Dockerized Jenkins server==============>")
    get_and_add_docker_jenkins_config(JENKINS_DOCKER_PATH)
    check_dockerised_jenkins_pem()

    #All variables are set and ready to call terraform
    os.chdir(TERRAFORM_FOLDER_PATH)

    subprocess.call('nohup ./scripts/create.sh >>../../stack_creation.out&',shell=True)
    subprocess.call('cp ./scripts/destroy.sh ../../'.split(' '))

    print("\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory to see the stack creation progress ")
    print(os.path.realpath('../../'))
    print("\n\n")
