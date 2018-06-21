#!/usr/bin/python
import os
import sys
import subprocess
from jazz_common import get_tfvars_file, replace_tfvars


def add_sonar_config_to_files(parameter_list):
    """
        Add Sonar configuration to terraform.tfvars
        parameter_list = [  sonar_server_elb ,
                            sonar_username,
                            sonar_passwd,
                            sonar_server_public_ip]
     """

    replace_tfvars('sonar_server_elb', parameter_list[0], get_tfvars_file())
    replace_tfvars('sonar_username', parameter_list[1], get_tfvars_file())
    replace_tfvars('sonar_passwd', parameter_list[2], get_tfvars_file())
    replace_tfvars('sonar_server_public_ip', parameter_list[4], get_tfvars_file())
    replace_tfvars('codequality_type', 'sonarqube', get_tfvars_file())
    replace_tfvars('codeq', 1, get_tfvars_file())



def check_sonar_user(url, username, passwd, token):
    """
        Check if the sonar user is present in Sonar server
    """
    sonar_url = 'http://' + url + '/api/user_tokens/search'
    if token:
        cmd = 'curl -u ' + token + ': '+ sonar_url
    else:
        cmd = 'curl -u ' + username + ':' + passwd + ' ' + sonar_url

    try:
        output = subprocess.check_output(cmd, shell=True)

        if not output:
            print output
            return 0
        else:
            return 1
    except:
        return 0


def get_add_existing_sonar_config(terraform_folder):
    """
        Get the exisintg Sonar server details from user,
        validate and change the config files.
    """
    os.chdir(terraform_folder)

    # Get Existing Sonar Details form user
    print "\nPlease provide Sonar Details.."
    sonar_server_elb = raw_input(
        "Sonar URL (Please ignore http from URL) :")
    sonar_username = raw_input("Sonar username :")
    sonar_passwd = raw_input("Sonar password :")

    # Check if the user provided Sonar user exist
    if check_sonar_user(sonar_server_elb, sonar_username,
                            sonar_passwd):
        print(
            "Great! We can proceed with this Sonar user....We will need few more details of Sonar server"
        )
    else:
        sys.exit(
            "Kindly provide an 'Admin' Sonar user with correct password and run the installer again!"
        )

    # Get Sonar public ip
    sonar_server_public_ip = raw_input("Sonar Server PublicIp :")

    # Create paramter list
    parameter_list = [
        sonar_server_elb, sonar_username, sonar_passwd,
        sonar_server_public_ip
    ]

    add_sonar_config_to_files(parameter_list)

def get_and_add_docker_sonar_config(sonar_docker_path):
    """
        Launch a dockerized Sonar server.
    """
    os.chdir(sonar_docker_path)
    print("Running docker launch script")
    subprocess.call([
        'sg', 'docker', './launch_sonar_docker.sh', '|', 'tee', '-a',
        '../../docker_creation.out'
    ])
    # Get values to create the array
    parameter_list = []
    with open("docker_sonar_vars") as f:
        for line in f:
            parameter_list.append(line.rstrip())

    print(parameter_list[0:])

    add_sonar_config_to_files(parameter_list)
