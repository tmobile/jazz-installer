import sys
import os
import stat
import subprocess
from .common import get_installer_root, get_tfvars_file, replace_tfvars


def get_atlassian_tools_path():
    return get_installer_root() + "/jazz_tmp/atlassian-cli-6.7.1/"


def check_bitbucket_user(url, username, passwd):
    """
        Check if the bitbucket user is present on the Bitbucket server
    """
    bitbucket_sh = get_installer_root() + "/jazz_tmp/atlassian-cli-6.7.1/bitbucket.sh"
    bitbucket_url = 'http://' + url + ''

    # Add execute bit for the current user to this shell script
    # since it was downloaded and not checked into Git
    perms = os.stat(bitbucket_sh)
    os.chmod(bitbucket_sh, perms.st_mode | stat.S_IEXEC)

    cmd = [
        bitbucket_sh, '--action', 'createproject', '--project', 'test000',
        '--name', 'test000', '--server', bitbucket_url, '--user', username,
        '--password', passwd
    ]

    try:
        output = str(subprocess.check_output(cmd))

        if not output.find("created"):
            print(output)
            return False
        else:
            cmd = [
                bitbucket_sh, '--action', 'deleteproject', '--project',
                'test000', '--server', bitbucket_url, '--user', username,
                '--password', passwd
            ]
            subprocess.check_call(cmd)
            return True
    except subprocess.CalledProcessError:
        return False


def configure_bitbucket(bbelb, bbuserpass, bbip):
    # Check if the user provided bitbucket user exist
    if check_bitbucket_user(bbelb, bbuserpass[0], bbuserpass[1]):
        print(
            "Great! We can proceed with this Bitbucket user....We will need few more details of Bitbucket server"
        )
    else:
        sys.exit(
            "Kindly provide an 'Admin' Bitbucket user with correct password and run the installer again!"
        )

    # Terraform provisioning script needs the jar file path
    replace_tfvars('atlassian_jar_path',
                   get_atlassian_tools_path() + "lib/bitbucket-cli-6.7.0.jar",
                   get_tfvars_file())
    replace_tfvars('scm_elb', bbelb, get_tfvars_file())
    replace_tfvars('scm_username', bbuserpass[0], get_tfvars_file())
    replace_tfvars('scm_passwd', bbuserpass[1], get_tfvars_file())
    replace_tfvars('scm_publicip', bbip, get_tfvars_file())
    replace_tfvars('scm_type', 'bitbucket', get_tfvars_file())
    replace_tfvars('scm_pathext', '/scm', get_tfvars_file())
