#!/usr/bin/python
import os
import sys
import subprocess

#Global variables
HOME_FOLDER = os.path.expanduser("~")
INSTALL_SCRIPT_FOLDER = HOME_FOLDER + "/jazz-installer/installscripts/"
JENKINS_COOKBOOK_SH = INSTALL_SCRIPT_FOLDER + "cookbooks/jenkins/files/credentials/gitlab-user.sh"
VARIABLES_TF_FILE = INSTALL_SCRIPT_FOLDER + "jazz-terraform-unix-noinstances/variables.tf"
SCM_TYPE = "gitlab"
DEV_NULL = open(os.devnull, 'w')

def add_gitlab_config_to_files(parameter_list):
    """
    Add gitlab configuration to variables.tf
    parameter_list = [  gitlab_public_ip ,
                        gitlab_username,
                        gitlab_passwd ]
    """
    print("Adding Gitlab config to Terraform variables")
    subprocess.call(['sed', '-i', "s|replaceip|%s|g" %(parameter_list[0]), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|replaceusername|%s|g" %(parameter_list[1]), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|replacepasswd|%s|g" %(parameter_list[2]), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|replacescmtype|%s|g" %(SCM_TYPE), VARIABLES_TF_FILE])
    subprocess.call(['sed', '-i', "s|replacescmPathExt|/|g" , VARIABLES_TF_FILE])

    # Adding gitlab username and password
    print("Adding Gitlab usernames and passwords")
    subprocess.call(['sed', '-i', "s|<username>gitlabuser</username>|<username>%s</username>|g" %(parameter_list[1]), JENKINS_COOKBOOK_SH])
    subprocess.call(['sed', '-i', "s|<password>gitlabpassword</password>|<password>%s</password>|g" %(parameter_list[2]), JENKINS_COOKBOOK_SH])


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
