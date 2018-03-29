#!/usr/bin/python
import os
import sys
import subprocess

from jazz_common import replace_tfvars, INSTALL_SCRIPT_FOLDER, TFVARS_FILE

def add_gitlab_config_to_files(parameter_list):
    """
    Add gitlab configuration to terraform.tfvars
    parameter_list = [  gitlab_public_ip ,
                        gitlab_username,
                        gitlab_passwd ]
    """
    print("Adding Gitlab config to Terraform variables")
    replace_tfvars('scm_publicip', parameter_list[0], TFVARS_FILE)
    replace_tfvars('scm_username', parameter_list[1], TFVARS_FILE)
    replace_tfvars('scm_passwd', parameter_list[2], TFVARS_FILE)
    replace_tfvars('scm_type', 'gitlab', TFVARS_FILE)
    replace_tfvars('scm_pathext', '/', TFVARS_FILE)

    # Adding gitlab username and password
    print("Adding Gitlab usernames and passwords")
    jenkinsCookbookSh = INSTALL_SCRIPT_FOLDER + "cookbooks/jenkins/files/credentials/gitlab-user.sh"

    subprocess.call(['sed', '-i', "s|<username>gitlabuser</username>|<username>%s</username>|g" %(parameter_list[1]), jenkinsCookbookSh])
    subprocess.call(['sed', '-i', "s|<password>gitlabpassword</password>|<password>%s</password>|g" %(parameter_list[2]), jenkinsCookbookSh])


def get_and_add_docker_gitlab_config(gitlab_docker_path):
    """
        Launch a Dockerized Gitlab server.
    """
    os.chdir(gitlab_docker_path)
    print("Running docker launch script  for gitlab")
    subprocess.call(['bash', 'launch_gitlab_docker.sh', '|', 'tee', '-a', '../../gitlab_creation.out'])
    print("Gitlab container launched")

    # Get values to create the array
    parameter_list = []
    with open("docker_gitlab_vars") as f:
        for line in f:
            parameter_list.append(line.rstrip())

    print(parameter_list[0:])

    add_gitlab_config_to_files(parameter_list)
