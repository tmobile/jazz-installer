from pathlib import Path
# TODO move this here?
from installer.configurators.common import get_terraform_folder
from installer.helpers.processwrap import tee_check_output, check_output, call, call_outputtofile
import datetime
import subprocess
import sys


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def exec_terraform_apply():
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    print(
        colors.OKBLUE + datetime.datetime.now().strftime('%c') + '\n' + colors.ENDC)

    stackDetails = get_terraform_folder() + '/stack_details.json'

    stackfile = Path(stackDetails)
    if stackfile.exists():
        stackfile.unlink()

    call(['terraform', 'init'], workdir=get_terraform_folder())

    # TODO see if we can avoid passing in AWS creds via env vars, if `awscli` is configured Terraform
    # will just use those preconfigured creds without any extra effort
    tfCommand = [
            'terraform', 'apply', '--auto-approve',
            '-var', 'aws_access_key=${AWS_ACCESS_KEY_ID}'
    ]

    if not tee_check_output(tfCommand, workdir=get_terraform_folder()):
        print(
            colors.FAIL + datetime.datetime.now().strftime('%c') + '\n' + colors.ENDC)

        print(
            colors.FAIL + 'Terraform apply failed!' + colors.ENDC)

        print(
            colors.WARNING + 'Destroying created AWS resources because of failure' + colors.ENDC)
        tee_check_output(['terraform', 'destroy', '--auto-approve'], workdir=get_terraform_folder())
    else:
        print(colors.OKGREEN + datetime.datetime.now().strftime('%c') + '\n' + colors.ENDC)
        print(colors.OKGREEN + 'Install succeded, generating stack_details.json...' + '\n' + colors.ENDC)
        get_terraform_output_json()


def exec_terraform_destroy():
    tfCommand = [
            'terraform', 'destroy', '--auto-approve'
    ]

    if not tee_check_output(tfCommand, workdir=get_terraform_folder()):
        print(
            colors.FAIL + datetime.datetime.now().strftime('%c') + '\n' + colors.ENDC)

        print(
            colors.FAIL + 'Terraform destroy failed! You can try re-running the uninstall' + colors.ENDC)
    else:
        print(
            colors.OKGREEN + datetime.datetime.now().strftime('%c') + '\n' + colors.ENDC)

        print(
            colors.OKGREEN + 'Terraform finished! AWS resources destroyed\n' + colors.ENDC)


def get_terraform_output_var(varname):
    try:
        return check_output(['terraform', 'output', varname], workdir=get_terraform_folder()).rstrip().decode('utf8')
    except subprocess.CalledProcessError:
        print("Failed getting output variable {0} from terraform!".format(varname))
        sys.exit()


def get_terraform_output_json():
    try:
        return call_outputtofile(['terraform', 'output', '-json'], 'stack_details.json', workdir=get_terraform_folder())
    except subprocess.CalledProcessError:
        print("Failed getting output as JSON from terraform!")
        sys.exit()
