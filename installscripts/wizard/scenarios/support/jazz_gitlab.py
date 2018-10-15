#!/usr/bin/python
import subprocess
import re
from ec2_metadata import ec2_metadata
from jazz_common import get_tfvars_file, replace_tfvars


def add_gitlab_config_to_files(parameter_list):
    """
    Add gitlab configuration to terraform.tfvars
    parameter_list = [  gitlab_public_ip ,
                        gitlab_username,
                        gitlab_passwd ]
    """
    print("Adding Gitlab config to Terraform variables")
    replace_tfvars('scm_publicip', parameter_list[0], get_tfvars_file())
    replace_tfvars('scm_elb', parameter_list[0], get_tfvars_file())
    replace_tfvars('scm_username', parameter_list[1], get_tfvars_file())
    replace_tfvars('scm_passwd', parameter_list[2], get_tfvars_file())
    replace_tfvars('scm_type', 'gitlab', get_tfvars_file())
    replace_tfvars('scm_pathext', '/', get_tfvars_file())


def get_and_add_docker_gitlab_config(gitlab_docker_path, parameter_cred_list=[]):
    """
        Launch a Dockerized Gitlab server.
    """
    scm_username = re.sub('[^a-zA-Z0-9_-]', '-', str(parameter_cred_list[0]))
    scm_passwd = str(parameter_cred_list[1])
    scm_publicip = str(ec2_metadata.public_ipv4)

    # Get values to create the array
    parameter_list = [scm_publicip, scm_username, scm_passwd]
    subprocess.call([
        'sed', "-i\'.bak\'",
        r's|\(scmbb = \)\(.*\)|\1false|g', get_tfvars_file()
    ])
    subprocess.call([
        'sed', "-i\'.bak\'",
        r's|\(scmgitlab = \)\(.*\)|\1true|g', get_tfvars_file()
    ])

    print(parameter_list[0:])

    add_gitlab_config_to_files(parameter_list)
