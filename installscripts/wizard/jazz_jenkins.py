#!/usr/bin/python
import os
import sys
import subprocess
import paramiko

# Global variables
HOME_FOLDER = os.path.expanduser("~")
TERRAFORM_FOLDER_PATH = HOME_FOLDER + "/jazz-installer/installscripts/jazz-terraform-unix-noinstances/"
VARIABLES_TF_FILE = TERRAFORM_FOLDER_PATH + "variables.tf"

HOME_JAZZ_INSTALLER = os.path.expanduser("~") + "/jazz-installer/"
JENKINS_CLI_PATH = HOME_JAZZ_INSTALLER + "installscripts/cookbooks/jenkins/files/default/"
JENKINS_CLI = JENKINS_CLI_PATH + "jenkins-cli.jar"
JENKINS_AUTH_FILE = HOME_JAZZ_INSTALLER + "installscripts/cookbooks/jenkins/files/default/authfile"

DEV_NULL = open(os.devnull, 'w')

def check_jenkins_sshuser_valid(parameter_list, port_number, keypath):
    """
        Check if the ssh login name is a user
    """
    jenkins_server_public_ip = parameter_list[3]
    jenkins_server_ssh_login = parameter_list[4]
    keyfile = keypath + "/jenkinskey.pem"
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(jenkins_server_public_ip, username=jenkins_server_ssh_login, key_filename=keyfile, port=port_number)
    except:
        sys.exit("Unable to SSH into the Jenkins instance! Is the jenkinskey key or the username valid?")


def add_jenkins_config_to_files(parameter_list):
    """
        Adding Jenkins Server configuration details to variables.tf
           parameter_list = [   jenkins_server_elb ,
                                jenkins_username,
                                jenkins_passwd,
                                jenkins_server_public_ip,
                                jenkins_server_ssh_login,
                                jenkins_server_ssh_port,
                                jenkins_server_security_group,
                                jenkins_server_subnet]
    """

    subprocess.call(['sed', '-i', "s|jenkins_elb.*.$|jenkins_elb=\"%s\"|g" %(parameter_list[0]), VARIABLES_TF_FILE])

    subprocess.call(['sed', '-i', "s|jenkinsuser.*.$|jenkinsuser=\"%s\"|g" %(parameter_list[1]), VARIABLES_TF_FILE])

    subprocess.call(['sed', '-i', "s|jenkinspasswd.*.$|jenkinspasswd=\"%s\"|g" %(parameter_list[2]), VARIABLES_TF_FILE])

    subprocess.call(['sed', '-i', "s|jenkins_public_ip.*.$|jenkins_public_ip=\"%s\"|g" %(parameter_list[3]), VARIABLES_TF_FILE])

    subprocess.call(['sed', '-i', "s|jenkins_ssh_login.*.$|jenkins_ssh_login=\"%s\"|g" %(parameter_list[4]), VARIABLES_TF_FILE])

    subprocess.call(['sed', '-i', "s|jenkins_ssh_port.*.$|jenkins_ssh_port=\"%s\"|g" %(parameter_list[5]), VARIABLES_TF_FILE])

    subprocess.call(['sed', '-i', "s|jenkins_security_group.*.$|jenkins_security_group=\"%s\"|g" %(parameter_list[6]), VARIABLES_TF_FILE])

    subprocess.call(['sed', '-i', "s|jenkins_subnet.*.$|jenkins_subnet=\"%s\"|g" %(parameter_list[7]), VARIABLES_TF_FILE])

    subprocess.call(['sed', '-i', "s|jenkinsuser:jenkinspasswd|%s:%s|g" %(parameter_list[1], parameter_list[2]), JENKINS_AUTH_FILE])


def check_jenkins_user(url, username, passwd):
    """
        Check if the jenkins user is present in Jenkins server
    """
    jenkins_url = 'http://' + url +''
    cmd = ['/usr/bin/java', '-jar', JENKINS_CLI, '-s', jenkins_url, 'who-am-i', '--username', username, '--password', passwd]
    subprocess.call(cmd, stdout=open("output", 'w'), stderr=open("output", 'w'))

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

    #Get Existing Jenkins Details form user
    print "\nPlease provide Jenkins Details.."
    jenkins_server_elb = raw_input("""\nInstaller would like to install and configure the following jenkins plugins.
    'https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#jenkins-plugins'
    If jenkins is already configured with any of these plugins, please provide a blank jenkins and continue.
    Yes to proceed and No to abort [y/n] :""")
    if jenkins_server_elb != 'y':
        sys.exit("")

    jenkins_server_elb = raw_input("Jenkins URL (Please ignore http and port number from URL) :")
    jenkins_username = raw_input("Jenkins username :")
    jenkins_passwd = raw_input("Jenkins password :")

    #Check is the jenkins user exist in jenkins server
    if check_jenkins_user(jenkins_server_elb, jenkins_username, jenkins_passwd):
        print("Great! We can proceed with this jenkins user....We will need few more details of Jenkins server")
    else:
        sys.exit("Kindly provide an 'Admin' Jenkins user with correct password and run the installer again!")

    #get the jenkinsserver public IP and SSH login
    jenkins_server_public_ip = raw_input("Jenkins Server PublicIp :")
    jenkins_server_ssh_login = raw_input("Jenkins Server SSH login name :")

    #Default Jenkins instance ssh Port
    jenkins_server_ssh_port = "22"

    #TODO - This is a temporary fix - We need to check why this is needed and should not ask this.
    jenkins_server_security_group = raw_input("Jenkins Server Security Group Name :")
    jenkins_server_subnet = raw_input("Jenkins Server Subnet :")

    #Create paramter list
    parameter_list = [  jenkins_server_elb ,
                        jenkins_username,
                        jenkins_passwd,
                        jenkins_server_public_ip,
                        jenkins_server_ssh_login,
                        jenkins_server_ssh_port,
                        jenkins_server_security_group,
                        jenkins_server_subnet]



    check_jenkins_sshuser_valid(parameter_list, jenkins_server_ssh_port, os.path.expanduser("~"))
    add_jenkins_config_to_files(parameter_list)

def get_and_add_docker_jenkins_config(jenkins_docker_path):
    """
        Launch a dockerized Jenkins server.
    """
    os.chdir(jenkins_docker_path)
    print("Running docker launch script")
    subprocess.call(['bash', 'launch_jenkins_docker.sh', '|', 'tee', '-a', '../../docker_creation.out'])

    # Get values to create the array
    parameter_list = []
    with open("docker_jenkins_vars") as f:
        for line in f:
            parameter_list.append(line.rstrip())

    print(parameter_list[0:])

    check_jenkins_sshuser_valid(parameter_list, 2200, jenkins_docker_path)
    add_jenkins_config_to_files(parameter_list)
