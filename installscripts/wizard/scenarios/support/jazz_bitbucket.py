#!/usr/bin/python
import os
import sys
import subprocess
from jazz_common import get_installer_root, get_tfvars_file, replace_tfvars


def add_bitbucket_config_to_files(parameter_list):
    """
        Add bitbucket configuration to terraform.tfvars
        parameter_list = [  bitbucket_server_elb ,
                            bitbucket_username,
                            bitbucket_passwd,
                            bitbucket_server_public_ip]
     """

    replace_tfvars('scm_elb', parameter_list[0], get_tfvars_file())
    replace_tfvars('scm_username', parameter_list[1], get_tfvars_file())
    replace_tfvars('scm_passwd', parameter_list[2], get_tfvars_file())
    replace_tfvars('scm_publicip', parameter_list[3], get_tfvars_file())
    replace_tfvars('scm_type', 'bitbucket', get_tfvars_file())
    replace_tfvars('scm_pathext', '/scm', get_tfvars_file())


def check_bitbucket_user(url, username, passwd):
    """
        Check if the bitbucket user is present in Bitbucket server
    """
    bitbucket_sh = get_installer_root() + "/jazz_tmp/atlassian-cli-6.7.1/bitbucket.sh"
    bitbucket_url = 'http://' + url + ''
    subprocess.call(['sudo', 'chmod', '+x', bitbucket_sh])
    cmd = [
        bitbucket_sh, '--action', 'createproject', '--project', 'test000',
        '--name', 'test000', '--server', bitbucket_url, '--user', username,
        '--password', passwd
    ]

    try:
        output = subprocess.check_output(cmd)

        if not output.find("created"):
            print output
            return 0
        else:
            cmd = [
                bitbucket_sh, '--action', 'deleteproject', '--project',
                'test000', '--server', bitbucket_url, '--user', username,
                '--password', passwd
            ]
            subprocess.check_output(cmd)
            return 1
    except:
        return 0


def get_and_add_existing_bitbucket_config(terraform_folder):
    """
        Get the exisintg Bitbucket server details from user,
        validate and change the config files.
    """
    os.chdir(terraform_folder)

    # Get Existing Bitbucket Details form user
    print "\nPlease provide Bitbucket Details.."
    bitbucket_server_elb = raw_input(
        "Bitbucket URL (Please ignore http and port number from URL) :")
    bitbucket_username = raw_input("Bitbucket username :")
    bitbucket_passwd = raw_input("Bitbucket password :")

    # Check if the user provided bitbucket user exist
    if check_bitbucket_user(bitbucket_server_elb, bitbucket_username,
                            bitbucket_passwd):
        print(
            "Great! We can proceed with this Bitbucket user....We will need few more details of Bitbucket server"
        )
    else:
        sys.exit(
            "Kindly provide an 'Admin' Bitbucket user with correct password and run the installer again!"
        )

    # Get bitbucket public ip
    bitbucket_server_public_ip = raw_input("Bitbucket Server PublicIp :")

    # Create paramter list
    parameter_list = [
        bitbucket_server_elb, bitbucket_username, bitbucket_passwd,
        bitbucket_server_public_ip
    ]

    add_bitbucket_config_to_files(parameter_list)
