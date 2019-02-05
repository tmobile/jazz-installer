#!/usr/bin/python
import os
import sys
import subprocess
import hashlib
import datetime
from jazz_common import get_tfvars_file, replace_tfvars, replace_tfvars_map


def add_jenkins_config_to_files(parameter_list):
    """
        Adding Jenkins Server configuration details to terraform.tfvars
           parameter_list = [   jenkins_server_elb ,
                                jenkins_username,
                                jenkins_passwd,
                                jenkins_server_public_ip,
                                jenkins_server_ssh_login,
                                jenkins_server_ssh_port,
                                jenkins_server_security_group,
                                jenkins_server_subnet]
    """

    replace_tfvars('jenkins_elb', parameter_list[0], get_tfvars_file())
    replace_tfvars('jenkinsuser', parameter_list[1], get_tfvars_file())
    replace_tfvars('jenkinspasswd', parameter_list[2], get_tfvars_file())
    replace_tfvars('jenkins_public_ip', parameter_list[3], get_tfvars_file())
    replace_tfvars('jenkins_ssh_login', parameter_list[4], get_tfvars_file())
    replace_tfvars('jenkins_ssh_port', parameter_list[5], get_tfvars_file())
    replace_tfvars('jenkins_security_group', parameter_list[6],
                   get_tfvars_file())
    replace_tfvars('jenkins_subnet', parameter_list[7], get_tfvars_file())


def check_jenkins_user(url, username, passwd):
    """
        Check if the jenkins user is present in Jenkins server
    """
    jenkins_url = 'http://' + url + ''
    # Download the CLI jar from the jenkins server
    subprocess.call([
        'curl', '-sL', jenkins_url + '/jnlpJars/jenkins-cli.jar', '-o',
        'jenkins-cli.jar'
    ])

    # Call the server and make sure user exists
    cmd = [
        'java', '-jar', 'jenkins-cli.jar', '-s', jenkins_url, 'who-am-i',
        '--username', username, '--password', passwd
    ]
    subprocess.call(
        cmd, stdout=open("output", 'w'), stderr=open("output", 'w'))

    if 'authenticated' in open('output').read():
        os.remove('output')
        return 1
    else:
        os.remove('output')
        return 0


def get_and_add_existing_jenkins_config(terraform_folder):
    """
        Get the exisintg Jenkins server details from user , validate and change
        the config files.
    """
    os.chdir(terraform_folder)

    # Get Existing Jenkins Details form user
    print "\nPlease provide Jenkins Details.."
    jenkins_server_elb = raw_input(
        """\nInstaller would like to install and configure the following \
        jenkins plugins.
    'https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#jenkins-plugins'
    If jenkins is already configured with any of these plugins, please \
        provide a blank jenkins and continue. \
    Yes to proceed and No to abort [y/n] :""")

    if jenkins_server_elb != 'y':
        sys.exit("")

    jenkins_server_elb = raw_input(
        "Jenkins URL (Please ignore http and port number from URL) :")
    jenkins_username = raw_input("Jenkins username :")
    jenkins_passwd = raw_input("Jenkins password :")

    # Check is the jenkins user exist in jenkins server
    if check_jenkins_user(jenkins_server_elb, jenkins_username,
                          jenkins_passwd):
        print(
            "Great! We can proceed with this jenkins user....We will need few more details of Jenkins server"
        )
    else:
        sys.exit(
            "Kindly provide an 'Admin' Jenkins user with correct password and run the installer again!"
        )

    # get the jenkinsserver public IP and SSH login
    jenkins_server_public_ip = raw_input("Jenkins Server PublicIp :")
    jenkins_server_ssh_login = raw_input("Jenkins Server SSH login name :")

    # Default Jenkins instance ssh Port
    jenkins_server_ssh_port = "22"

    # TODO - This is a temporary fix - We need to check why this is needed and should not ask this.
    jenkins_server_security_group = raw_input(
        "Jenkins Server Security Group Name :")
    jenkins_server_subnet = raw_input("Jenkins Server Subnet :")

    # Create paramter list
    parameter_list = [
        jenkins_server_elb, jenkins_username, jenkins_passwd,
        jenkins_server_public_ip, jenkins_server_ssh_login,
        jenkins_server_ssh_port, jenkins_server_security_group,
        jenkins_server_subnet
    ]

    replace_tfvars_map("dockerizedJenkins", "false", get_tfvars_file())

    add_jenkins_config_to_files(parameter_list)


def get_and_add_docker_jenkins_config(jenkins_docker_path):
    """
        Launch a dockerized Jenkins server.
    """
    encrypt_passwd = hashlib.md5()
    encrypt_passwd.update(str(datetime.datetime.now()))
    jenkins_passwd = encrypt_passwd.hexdigest()

    use_existing_vpc = raw_input(
        """\nWould you like to use existing VPC for ECS? [y/n] :""")
    if use_existing_vpc == 'y':
        existing_vpc_id = raw_input("Enter the VPC ID :")
        replace_tfvars('existing_vpc_ecs', existing_vpc_id, get_tfvars_file())
    else:
        replace_tfvars_map("autovpc", "true", get_tfvars_file())
        desired_vpc_cidr = raw_input("Enter the desired CIDR for VPC (default - 10.0.0.0/16) :") or "10.0.0.0/16"
        replace_tfvars("vpc_cidr_block", desired_vpc_cidr, get_tfvars_file())

    # Get values to create the array
    parameter_list = ["replaceme", "admin", jenkins_passwd, "replaceme",
                      "root", "2200", "replaceme", "replaceme"]
    print(parameter_list[0:])

    add_jenkins_config_to_files(parameter_list)
