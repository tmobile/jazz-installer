import sys
import subprocess
from .common import get_tfvars_file, replace_tfvars


def update_sonarqube_terraform(sonarelb, sonaruserpass, sonarip):
    replace_tfvars('sonar_server_elb', sonarelb, get_tfvars_file())
    replace_tfvars('sonar_username', sonaruserpass[0], get_tfvars_file())
    replace_tfvars('sonar_passwd', sonaruserpass[1], get_tfvars_file())
    replace_tfvars('sonar_server_public_ip', sonarip, get_tfvars_file())
    replace_tfvars('codequality_type', 'sonarqube', get_tfvars_file())
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
        subprocess.check_call(cmd, shell=True)
        return True
    except subprocess.CalledProcessError:
        return False


def configure_sonarqube(sonarelb, sonaruserpass, sonarip):
    """
        Get the exisintg Sonar server details from user,
        validate and change the config files.
    """

    # Check if the user provided Sonar user exist
    if check_sonar_user(sonarelb, sonaruserpass[0], sonaruserpass[1]):
        print(
            "Great! We can proceed with this Sonar user....We will need few more details of Sonar server"
        )
    else:
        sys.exit(
            "Kindly provide an 'Admin' Sonar user with correct password and run the installer again!"
        )
    update_sonarqube_terraform(sonarelb, sonaruserpass, sonarip)
