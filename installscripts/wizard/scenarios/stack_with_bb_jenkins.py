#!/usr/bin/python
import os
import sys
import subprocess
from jazz_common import parse_and_replace_paramter_list
from jazz_jenkins import get_and_add_existing_jenkins_config
from jazz_bitbucket import get_and_add_existing_bitbucket_config

#Global variables
HOME_FOLDER = os.path.expanduser("~")
HOME_JAZZ_INSTALLER = HOME_FOLDER + "/jazz-installer/"
HOME_INSTALL_SCRIPTS = HOME_JAZZ_INSTALLER + "installscripts/"
TERRAFORM_FOLDER_PATH = HOME_INSTALL_SCRIPTS + "jazz-terraform-unix-noinstances"
VARIABLES_TF_FILE = TERRAFORM_FOLDER_PATH + "variables.tf"
JENKINS_PEM = HOME_FOLDER + "/jenkinskey.pem"
BITBUCKET_PEM = HOME_FOLDER + "/bitbucketkey.pem"

def pause():
    programPause = raw_input("Press the <ENTER> key to continue...")

def check_jenkins_bitbucket_pem():
    """
        Check if the user has provided jenkinskey.pem and bitbucketkey.pem
    """
    print(" Please make sure that you have the ssh login user names of jenkins and bitbucket servers.")
    print(" Please create jenkinskey.pem and bitbucketkey.pem with private keys of Jenkins and Bitbucket in /home/ec2-user")
    pause()

    #Chck if both files are been added to home derectory
    if not os.path.isfile(JENKINS_PEM):
        sys.exit("File jenkinskey.pem is not present in your home (~/) folder, kindly add and run the installer again! ")
    if not os.path.isfile(BITBUCKET_PEM):
        sys.exit("File bitbucketkey.pem is not present in your home (~/) folder, kindly add and run the installer again! ")

    #Copy the pem keys and give relavant permisions
    subprocess.call('cp -f {0} {1}sshkeys'.format(JENKINS_PEM, HOME_INSTALL_SCRIPTS).split(' '))
    subprocess.call('sudo chmod 400 {0}sshkeys/jenkinskey.pem'.format(HOME_INSTALL_SCRIPTS).split(' '))
    subprocess.call('cp -f {0} {1}sshkeys'.format(BITBUCKET_PEM, HOME_INSTALL_SCRIPTS).split(' '))
    subprocess.call('sudo chmod 400 {0}sshkeys/bitbucketkey.pem'.format(HOME_INSTALL_SCRIPTS).split(' '))


def start(parameter_list):
    """
        start stack creation
    """
    # Parse the parameter list
    parse_and_replace_paramter_list(TERRAFORM_FOLDER_PATH, parameter_list)
    os.chdir(TERRAFORM_FOLDER_PATH)

    # Get Jenkins configuration details
    get_and_add_existing_jenkins_config(TERRAFORM_FOLDER_PATH)

    # Get Bitbucket configuration details    
    get_and_add_existing_bitbucket_config(TERRAFORM_FOLDER_PATH)

    # Make Sure Jenkins and Bitbucket pem files are present in home folder
    check_jenkins_bitbucket_pem()

    #All variables are set and ready to call terraform
    os.chdir(TERRAFORM_FOLDER_PATH)

    subprocess.call('nohup ./scripts/create.sh >>../../stack_creation.out&',shell=True)
    subprocess.call('cp ./scripts/destroy.sh ../../'.split(' '))
    
    print("\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory to see the stack creation progress ")
    print(os.path.realpath('../../'))
    print("\n\n")

