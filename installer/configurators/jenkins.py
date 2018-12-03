import subprocess
import os
import sys
from pathlib import Path
# TODO see if we really need to split these files this way
from installer.configurators.jenkins import configure_jenkins_docker
from installer.configurators.common import get_script_folder, get_installer_root, get_tfvars_file, replace_tfvars, passwd_generator


def check_jenkins_pem():
    """
        Check if the user has provided jenkinskey.pem
    """
    print(
        " Please make sure that you have the ssh login user names of jenkins and bitbucket servers."
    )
    # Check if file is been added to home derectory
    jenkins_pem = get_installer_root() + "/jenkinskey.pem"
    if not Path.is_file(jenkins_pem):
        sys.exit(
            "File jenkinskey.pem not found in installer root directory, kindly add and run the installer again! "
        )

    # Copy the pem keys and give relavant permisions
    subprocess.call('cp -f {0} {1}sshkeys'.format(
        jenkins_pem, get_script_folder()).split(' '))
    subprocess.call('sudo chmod 400 {0}sshkeys/jenkinskey.pem'.format(
        get_script_folder()).split(' '))


def check_jenkins_user(url, usernamepw):
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


# TODO do we need SSHuser and crap for dockerized scenarios?
def update_jenkins_terraform(elb, userpw, ip, sshuser, ssh_port, secgrp, subnet):
    replace_tfvars('jenkins_elb', elb, get_tfvars_file())
    replace_tfvars('jenkinsuser', userpw[0], get_tfvars_file())
    replace_tfvars('jenkinspasswd', userpw[1], get_tfvars_file())
    replace_tfvars('jenkins_public_ip', ip, get_tfvars_file())
    replace_tfvars('jenkins_ssh_login', sshuser, get_tfvars_file())
    replace_tfvars('jenkins_ssh_port', ssh_port, get_tfvars_file())
    replace_tfvars('jenkins_security_group', secgrp, get_tfvars_file())
    replace_tfvars('jenkins_subnet', subnet, get_tfvars_file())


def configure_jenkins(elb, userpw, ip, sshuser, secgrp, subnet):
    # Check is the jenkins user exist in jenkins server
    if not check_jenkins_user(elb, userpw):
        sys.exit(
            "Kindly provide an 'Admin' Jenkins user with correct password and run the installer again!"
        )

    check_jenkins_pem()

    # Default Jenkins instance ssh Port
    ssh_port = "22"

    replace_tfvars('dockerizedJenkins', 'false', get_tfvars_file(), quoteVal=False)
    update_jenkins_terraform(elb, userpw, ip, sshuser, ssh_port, secgrp, subnet)


def configure_jenkins_docker(existing_vpc_id, vpc_cidr):
    """
        Launch a containerized Jenkins server.
    """
    if existing_vpc_id:
        replace_tfvars('existing_vpc_ecs', existing_vpc_id, get_tfvars_file())
    else:
        replace_tfvars("autovpc", "true", get_tfvars_file(), False)
        replace_tfvars("vpc_cidr_block", vpc_cidr, get_tfvars_file())

    # res = launch_dockerized_jenkins()
    update_jenkins_terraform("replaceme", ("admin", passwd_generator()), "replaceme",
                             "root", "2200", "replaceme", "replaceme")
