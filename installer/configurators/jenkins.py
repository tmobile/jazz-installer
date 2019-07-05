import subprocess
import os
import sys
from pathlib import Path
from installer.configurators.common import get_installer_root, get_tfvars_file, replace_tfvars

jenkins_pem = get_installer_root() + "/jenkinskey.pem"


def check_jenkins_pem():
    """
        Check if the user has provided jenkinskey.pem
    """
    print(
        " Please make sure that you have the ssh login user names of jenkins and bitbucket servers."
    )
    # Check if user dropped the jenkins key into the installer root (scenario 1 only)
    if not Path(jenkins_pem).is_file():
        sys.exit(
            "File jenkinskey.pem not found in installer root directory, kindly add and run the installer again! "
        )

    # Make sure the PEM the user dropped in has the right perms
    subprocess.call(['chmod', '400', '{0}'.format(jenkins_pem)])


def check_jenkins_user(url, defaultport, usernamepw):
    """
        Check if the jenkins user is present in Jenkins server
    """
    jenkins_url = 'http://{0}:{1}'.format(url, defaultport)
    # Download the CLI jar from the jenkins server
    subprocess.call([
        'curl', '-sL', jenkins_url + '/jnlpJars/jenkins-cli.jar', '-o',
        'jenkins-cli.jar'
    ])

    # Call the server and make sure user exists
    cmd = [
        'java', '-jar', 'jenkins-cli.jar', '-s', jenkins_url, 'who-am-i',
        '--username', usernamepw[0], '--password', usernamepw[1]
    ]
    subprocess.call(
        cmd, stdout=open("output", 'w'), stderr=open("output", 'w'))

    if 'authenticated' in open('output').read():
        os.remove('output')
        return 1
    else:
        os.remove('output')
        return 0


def update_jenkins_terraform(endpoint, defaultport, userpw, sshuser, ssh_port, secgrp, subnet):
    replace_tfvars('jenkins_elb', '{0}:{1}'.format(endpoint, defaultport), get_tfvars_file())
    replace_tfvars('jenkins_rawendpoint', endpoint, get_tfvars_file())
    replace_tfvars('jenkins_security_group', secgrp, get_tfvars_file())
    replace_tfvars('jenkins_subnet', subnet, get_tfvars_file())
    replace_tfvars('jenkinsuser', userpw[0], get_tfvars_file())
    replace_tfvars('jenkinspasswd', userpw[1], get_tfvars_file())
    replace_tfvars('jenkins_ssh_login', sshuser, get_tfvars_file())
    replace_tfvars('jenkins_ssh_port', ssh_port, get_tfvars_file())
    replace_tfvars('jenkins_ssh_key', '{0}'.format(jenkins_pem), get_tfvars_file())

def configure_jenkins(endpoint, defaultport, userpw, sshuser, secgrp, subnet, existing_vpc_id, vpc_cidr):
    # Check is the jenkins user exist in jenkins server
    if not check_jenkins_user(endpoint, defaultport, userpw):
        sys.exit(
            "Kindly provide an 'Admin' Jenkins user with correct password and run the installer again!"
        )

    check_jenkins_pem()

    # Default Jenkins instance ssh Port
    ssh_port = "22"
    if existing_vpc_id:
        replace_tfvars('existing_vpc_ecs', existing_vpc_id, get_tfvars_file())
    else:
        replace_tfvars("autovpc", "true", get_tfvars_file(), False)
        replace_tfvars("vpc_cidr_block", vpc_cidr, get_tfvars_file())

    replace_tfvars('dockerizedJenkins', 'false', get_tfvars_file(), quoteVal=False)
    update_jenkins_terraform(endpoint, defaultport, userpw, sshuser, ssh_port, secgrp, subnet)
