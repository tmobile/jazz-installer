#!/usr/bin/python
import os
import sys
import subprocess
from jazz_common import replace_tfvars

#Global variables
HOME_FOLDER = os.path.expanduser("~")
TERRAFORM_FOLDER_PATH = HOME_FOLDER + "/jazz-installer/installscripts/jazz-terraform-unix-noinstances/"
TFVARS_FILE = TERRAFORM_FOLDER_PATH + "terraform.tfvars"

INSTALL_SCRIPT_FOLDER = HOME_FOLDER + "/jazz-installer/installscripts/"
JENKINS_COOKBOOK_SH = INSTALL_SCRIPT_FOLDER + "cookbooks/jenkins/files/credentials/jenkins1.sh"
BITBUCKET_SH = HOME_FOLDER + "/atlassian-cli-6.7.1/bitbucket.sh"
DEV_NULL = open(os.devnull, 'w')

def add_bitbucket_config_to_files(parameter_list):
    """
        Add bitbucket configuration to vriables.tf
        parameter_list = [  bitbucket_server_elb ,
                            bitbucket_username,
                            bitbucket_passwd,
                            bitbucket_server_public_ip]
     """
    #TODO make this key more specific
    replace_tfvars('scm_elb', parameter_list[0], TFVARS_FILE)
    replace_tfvars('scm_username', parameter_list[1], TFVARS_FILE)
    replace_tfvars('scm_passwd', parameter_list[2], TFVARS_FILE)
    replace_tfvars('scm_publicip', parameter_list[3], TFVARS_FILE)
    replace_tfvars('scm_type', 'bitbucket', TFVARS_FILE)
    replace_tfvars('scm_pathext', '/scm', TFVARS_FILE)

    #Adding bitbucket username and password
    subprocess.call(['sed', '-i', "s|<username>bitbucketuser</username>|<username>%s</username>|g" %(parameter_list[1]), JENKINS_COOKBOOK_SH])
    subprocess.call(['sed', '-i', "s|<password>bitbucketpasswd</password>|<password>%s</password>|g" %(parameter_list[2]), JENKINS_COOKBOOK_SH])


def check_bitbucket_user(url, username, passwd):
    """
        Check if the bitbucket user is present in Bitbucket server
    """
    bitbucket_url = 'http://'+ url +''
    subprocess.call(['sudo', 'chmod', '+x', BITBUCKET_SH])
    cmd = [ BITBUCKET_SH , '--action', 'createproject', '--project', 'test000', '--name', 'test000', '--server', bitbucket_url, '--user', username, '--password', passwd]

    try:
        output = subprocess.check_output(cmd)

        if not output.find("created"):
            print output
            return 0
        else:
            cmd = [BITBUCKET_SH, '--action', 'deleteproject', '--project', 'test000', '--server', bitbucket_url, '--user', username, '--password', passwd]
            subprocess.check_output(cmd)
            return 1
    except:
        return 0


def get_and_add_existing_bitbucket_config(terraform_folder):
    """
        Get the exisintg Bitbucket server details from user , validate and change
        the config files.
    """
    os.chdir(terraform_folder)

    #Get Existing Bitbucket Details form user
    print "\nPlease provide Bitbucket Details.."
    bitbucket_server_elb = raw_input("Bitbucket URL (Please ignore http and port number from URL) :")
    bitbucket_username = raw_input("Bitbucket username :")
    bitbucket_passwd = raw_input("Bitbucket password :")

    #Check if the user provided bitbucket user exist
    if check_bitbucket_user(bitbucket_server_elb, bitbucket_username, bitbucket_passwd):
        print("Great! We can proceed with this Bitbucket user....We will need few more details of Bitbucket server")
    else:
        sys.exit("Kindly provide an 'Admin' Bitbucket user with correct password and run the installer again!")

    #Get bitbucket public ip
    bitbucket_server_public_ip = raw_input("Bitbucket Server PublicIp :")

    #Create paramter list
    parameter_list = [  bitbucket_server_elb ,
                        bitbucket_username,
                        bitbucket_passwd,
                        bitbucket_server_public_ip]

    add_bitbucket_config_to_files(parameter_list)
