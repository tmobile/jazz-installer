#!/usr/bin/python
import os
import sys
import subprocess
from jazz_common import replace_tfvars, INSTALL_SCRIPT_FOLDER, TFVARS_FILE


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

    replace_tfvars('jenkins_elb', parameter_list[0], TFVARS_FILE)
    replace_tfvars('jenkinsuser', parameter_list[1], TFVARS_FILE)
    replace_tfvars('jenkinspasswd', parameter_list[2], TFVARS_FILE)
    replace_tfvars('jenkins_public_ip', parameter_list[3], TFVARS_FILE)
    replace_tfvars('jenkins_ssh_login', parameter_list[4], TFVARS_FILE)
    replace_tfvars('jenkins_ssh_port', parameter_list[5], TFVARS_FILE)
    replace_tfvars('jenkins_security_group', parameter_list[6], TFVARS_FILE)
    replace_tfvars('jenkins_subnet', parameter_list[7], TFVARS_FILE)


def check_jenkins_user(url, username, passwd):
    """
        Check if the jenkins user is present in Jenkins server
    """
    jenkins_cli = INSTALL_SCRIPT_FOLDER + "/cookbooks/jenkins/files/default/jenkins-cli.jar"
    jenkins_url = 'http://' + url + ''

    cmd = [
        'java', '-jar', jenkins_cli, '-s', jenkins_url, 'who-am-i',
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
        """\nInstaller would like to install and configure the following jenkins plugins.
    'https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#jenkins-plugins'
    If jenkins is already configured with any of these plugins, please provide a blank jenkins and continue.
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

    add_jenkins_config_to_files(parameter_list)


def get_and_add_docker_jenkins_config(jenkins_docker_path):
    """
        Launch a dockerized Jenkins server.
    """
    os.chdir(jenkins_docker_path)
    print("Running docker-ce install script")
    subprocess.call([
        'sh', 'install_docker_centos.sh', '|', 'tee', '-a',
        '../../docker_creation.out'
    ])
    print("Running docker launch script")
    subprocess.call([
        'sg', 'docker', './launch_jenkins_docker.sh', '|', 'tee', '-a',
        '../../docker_creation.out'
    ])
    # Get values to create the array
    parameter_list = []
    with open("docker_jenkins_vars") as f:
        for line in f:
            parameter_list.append(line.rstrip())

    print(parameter_list[0:])

    add_jenkins_config_to_files(parameter_list)
