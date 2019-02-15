#!/usr/bin/python
import os
import sys
import subprocess
from support.jazz_common import parse_and_replace_parameter_list, get_script_folder, get_terraform_folder, get_installer_root
from support.jazz_jenkins import get_and_add_existing_jenkins_config
from support.jazz_bitbucket import get_and_add_existing_bitbucket_config
from support.jazz_sonar import get_add_existing_sonar_config


def pause():
    programPause = raw_input("Press the <ENTER> key to continue...")


def check_jenkins_pem():
    """
        Check if the user has provided jenkinskey.pem
    """
    print(
        " Please make sure that you have the ssh login user names of jenkins and bitbucket servers."
    )
    print(
        " Please place the private key to your Jenkins server in the installer root directory with a filenameof 'jenkinskey.pem"
    )

    pause()

    # Check if file is been added to home derectory
    jenkins_pem =  get_installer_root() + "/jenkinskey.pem"
    if not os.path.isfile(jenkins_pem):
        sys.exit(
            "File jenkinskey.pem not found in installer root directory, kindly add and run the installer again! "
        )

    # Copy the pem keys and give relavant permisions
    subprocess.call('cp -f {0} {1}sshkeys'.format(
        jenkins_pem, get_script_folder()).split(' '))
    subprocess.call('sudo chmod 400 {0}sshkeys/jenkinskey.pem'.format(
        get_script_folder()).split(' '))


def start(parameter_list):
    """
        start stack creation
    """
    # Parse the parameter list
    parse_and_replace_parameter_list(get_terraform_folder(), parameter_list)
    os.chdir(get_terraform_folder())

    # Get Jenkins configuration details
    get_and_add_existing_jenkins_config(get_terraform_folder())

    # Get Bitbucket configuration details
    get_and_add_existing_bitbucket_config(get_terraform_folder())

    if os.environ['CODE_QUALITY'] == 'true':
        # Get Sonar configuration details
        get_add_existing_sonar_config(get_terraform_folder())

    # Make Sure Jenkins pem file is present in home folder
    check_jenkins_pem()

    # All variables are set and ready to call terraform
    os.chdir(get_terraform_folder())

    subprocess.call(
        'nohup ./scripts/create.sh >>../../stack_creation.out&', shell=True)
    subprocess.call('cp ./scripts/destroy.sh ../../'.split(' '))
    subprocess.call('cp ./scripts/triggerJenkinsDeleteResources.py ../../'.split(' '))

    print(
        "\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory to see the stack creation progress "
    )
    print(os.path.realpath('../../'))
    print("\n\n")
