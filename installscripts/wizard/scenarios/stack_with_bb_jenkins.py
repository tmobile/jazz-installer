#!/usr/bin/python
import os
import sys
import subprocess
from jazz_common import parse_and_replace_parameter_list, INSTALL_SCRIPT_FOLDER, TERRAFORM_FOLDER_PATH, HOME_FOLDER
from jazz_jenkins import get_and_add_existing_jenkins_config
from jazz_bitbucket import get_and_add_existing_bitbucket_config

def pause():
    programPause = raw_input("Press the <ENTER> key to continue...")

def check_jenkins_pem():
    """
        Check if the user has provided jenkinskey.pem
    """
    print(" Please make sure that you have the ssh login user names of jenkins and bitbucket servers.")
    print(" Please create jenkinskey.pem  with private keys of Jenkins Server in your home directory")
    pause()

    #Check if file is been added to home derectory
    jenkins_pem = HOME_FOLDER + "/jenkinskey.pem"
    if not os.path.isfile(jenkins_pem):
        sys.exit("File jenkinskey.pem is not present in your home (~/) folder, kindly add and run the installer again! ")

    #Copy the pem keys and give relavant permisions
    subprocess.call('cp -f {0} {1}sshkeys'.format(jenkins_pem, INSTALL_SCRIPT_FOLDER).split(' '))
    subprocess.call('sudo chmod 400 {0}sshkeys/jenkinskey.pem'.format(INSTALL_SCRIPT_FOLDER).split(' '))


def start(parameter_list):
    """
        start stack creation
    """
    # Parse the parameter list
    parse_and_replace_parameter_list(TERRAFORM_FOLDER_PATH, parameter_list)
    os.chdir(TERRAFORM_FOLDER_PATH)

    # Get Jenkins configuration details
    get_and_add_existing_jenkins_config(TERRAFORM_FOLDER_PATH)

    # Get Bitbucket configuration details
    get_and_add_existing_bitbucket_config(TERRAFORM_FOLDER_PATH)

    # Make Sure Jenkins pem file is present in home folder
    check_jenkins_pem()

    #All variables are set and ready to call terraform
    os.chdir(TERRAFORM_FOLDER_PATH)

    subprocess.call('nohup ./scripts/create.sh >>../../stack_creation.out&',shell=True)
    subprocess.call('cp ./scripts/destroy.sh ../../'.split(' '))

    print("\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory to see the stack creation progress ")
    print(os.path.realpath('../../'))
    print("\n\n")
