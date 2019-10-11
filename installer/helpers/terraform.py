from pathlib import Path
# TODO move this here?
from installer.configurators.common import get_terraform_folder
from installer.helpers.processwrap import tee_check_output, check_output, call
import datetime
import subprocess
import sys
import json
import os
from collections import OrderedDict


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

    call(['terraform', 'init'], workdir=get_terraform_folder())

    # TODO see if we can avoid passing in AWS creds via env vars, if `awscli` is configured Terraform
    # will just use those preconfigured creds without any extra effort
    tfCommand = [
            'terraform', 'apply', '--auto-approve',
            '-var', 'aws_access_key=%s' % (os.environ['AWS_ACCESS_KEY_ID']),
            '-var', 'aws_secret_key=%s' % (os.environ['AWS_SECRET_ACCESS_KEY'])
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
        generate_stack_details()


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


# All we're doing here is taking values already stored as output variables
# in terraform and translating them to a specific JSON format
# `terraform output -json` would already do this for us, but we have some internal
# scripts and tools that rely on this specific old format so we still need this translation logic
# If those tools are ever updated to handle the terraform output json directly we can drop this
def generate_stack_details():
    # Delete old stack_details.json if it's still
    # hanging around from a previous run
    stackDetails = get_terraform_folder() + '/stack_details.json'

    stackfile = Path(stackDetails)
    if stackfile.exists():
        stackfile.unlink()

    output = OrderedDict()
    key_common_list = OrderedDict(
        [("jenkinselb", "Jenkins ELB"), ("jenkinsuser", "Jenkins Username"),
         ("jenkinspasswd", "Jenkins Password"), ("jazzhome", "Jazz Home"),
         ("jazzusername", "Jazz Admin Username"), ("jazzpassword",
                                                   "Jazz Admin Password"),
         ("region", "Region"), ("apiendpoint", "Jazz API Endpoint")])
    output = generate_dict(key_common_list, output)

    if get_terraform_output_var("codeq") == "1":
        key_codeq_list = OrderedDict([("sonarhome", "Sonar Home"),
                                      ("sonarusername", "Sonar Username"),
                                      ("sonarpasswd", "Sonar Password")])
        output = generate_dict(key_codeq_list, output)

    if get_terraform_output_var("scmbb") == "1":
        key_bb_list = OrderedDict([("scmelb", "Bitbucket ELB"),
                                   ("scmusername", "Bitbucket Username"),
                                   ("scmpasswd", "Bitbucket Password")])
        output = generate_dict(key_bb_list, output)

    if get_terraform_output_var("scmgitlab") == "1":
        key_gitlab_list = OrderedDict([("scmelb", "Gitlab Home"),
                                       ("scmusername", "Gitlab Username"),
                                       ("scmpasswd", "Gitlab Password")])
        output = generate_dict(key_gitlab_list, output)

    with open("stack_details.json", 'w+') as file:
        file.write(json.dumps(output, indent=4))


def generate_dict(outputkeys, output):
    for opkey, key in outputkeys.items():
        output.update({key: get_terraform_output_var(opkey)})
    return output
