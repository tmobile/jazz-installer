#!/usr/bin/python
import os
import sys
import subprocess
from support.jazz_common import get_script_folder, get_jenkins_pem, get_docker_path, get_terraform_folder, \
                                parse_and_replace_parameter_list
from support.jazz_jenkins import get_and_add_docker_jenkins_config
from support.jazz_gitlab import get_and_add_docker_gitlab_config
from support.jazz_sonar import get_and_add_docker_sonar_config


def check_jenkins_pem():
    """
        Check if the user has provided jenkinskey.pem private keys
    """
    # Check if both files are been added to home derectory
    if not os.path.isfile(get_jenkins_pem()):
        sys.exit(
            "File jenkinskey.pem is not present in your home (~/) folder, kindly add and run the installer again! "
        )

    # Copy the pem keys and give relavant permissions to a dockerkeys location. This is different from Scenario 1.
    subprocess.call('cp -f {0} {1}sshkeys/dockerkeys'.format(
        get_jenkins_pem(), get_script_folder()).split(' '))
    subprocess.call(
        'sudo chmod 400 {0}sshkeys/dockerkeys/jenkinskey.pem'.format(
            get_script_folder()).split(' '))


def start(parameter_list):
    """
        start stack creation
    """
    parse_and_replace_parameter_list(get_terraform_folder(), parameter_list)

    if os.environ['CODE_QUALITY'] == 'true':
        get_and_add_docker_sonar_config(get_docker_path() + "/sonar/")

    get_and_add_docker_jenkins_config(get_docker_path() + "/jenkins-ce/")

    # Deploy Gitlab docker and get configuration details
    get_and_add_docker_gitlab_config(get_docker_path() + "/gitlab/", parameter_list[1])

    # All variables are set and ready to call terraform
    os.chdir(get_terraform_folder())

    print("Invoking Terraform==============================>")
    subprocess.call(
        'nohup ./scripts/create.sh | tee ../../stack_creation.out&',
        shell=True)
    print("Copying Terraform destroy script================>")
    subprocess.call('cp ./scripts/destroy.sh ../../'.split(' '))
    subprocess.call('cp ./scripts/triggerJenkinsDeleteResources.py ../../'.split(' '))

    print(
        "\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory \
        to see the stack creation progress "
    )
    print(os.path.realpath('../../'))
    print("\n\n")
