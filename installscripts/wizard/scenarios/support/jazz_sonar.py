#!/usr/bin/python
import os
import sys
import subprocess
import hashlib
import datetime
from ec2_metadata import ec2_metadata
from jazz_common import get_tfvars_file, replace_tfvars, replace_tfvars_map


def add_sonar_config_to_files(sonar_server_elb, sonar_username, sonar_passwd):
    """
        Add Sonar configuration to terraform.tfvars
     """

    replace_tfvars('sonar_server_elb', sonar_server_elb, get_tfvars_file())
    replace_tfvars('sonar_username', sonar_username, get_tfvars_file())
    replace_tfvars('sonar_passwd', sonar_passwd, get_tfvars_file())
    replace_tfvars('codeq', 1, get_tfvars_file())


def check_sonar_user(url, username, passwd, token):
    """
        Check if the sonar user is present in Sonar server
    """
    sonar_url = 'http://' + url + '/api/user_tokens/search'
    if token:
        cmd = 'curl -u ' + token + ': ' + sonar_url
    else:
        cmd = 'curl -u ' + username + ':' + passwd + ' ' + sonar_url

    try:
        output = subprocess.check_output(cmd, shell=True)

        if not output:
            print output
            return 0
        else:
            return 1
    except Exception:
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
    if check_sonar_user(sonar_server_elb, sonar_username, sonar_passwd):
        print(
            "Great! We can proceed with this Sonar user....We will need few more details of Sonar server"
        )
    else:
        sys.exit(
            "Kindly provide an 'Admin' Sonar user with correct password and run the installer again!"
        )
    add_sonar_config_to_files(sonar_server_elb, sonar_username, sonar_passwd)


def get_and_add_docker_sonar_config(sonar_docker_path):
    """
        Launch a dockerized Sonar server.
    """
    encrypt_passwd = hashlib.md5()
    encrypt_passwd.update(str(datetime.datetime.now()))
    sonar_passwd = encrypt_passwd.hexdigest()
    sonar_server_elb = str(ec2_metadata.public_ipv4)
    replace_tfvars_map("dockerizedSonarqube", "true", get_tfvars_file())
    add_sonar_config_to_files(sonar_server_elb, "admin", sonar_passwd)
