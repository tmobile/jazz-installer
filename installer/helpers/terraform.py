from pathlib import Path
# TODO move this here?
from installer.configurators.common import get_terraform_folder
from installer.helpers.processwrap import tee_check_output, check_call, call
import datetime


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
        check_call(['terraform', 'destroy', '--auto-approve'], workdir=get_terraform_folder())
    else:
        # # Use Popen so we can echo to shell and capture log
        # with Popen(
        #         tfCommand,
        #         cwd=get_terraform_folder(),
        #         stdout=PIPE,
        #         stderr=STDOUT,
        #         bufsize=1
        # ) as p, open('stack_creation.out', 'ab') as file:
        #     for line in p.stdout:  # b'\n'-separated lines
        #         sys.stdout.buffer.write(line)  # pass bytes as is
        #         file.write(line)
        print(
            colors.OKGREEN + datetime.datetime.now().strftime('%c') + '\n' + colors.ENDC)

        print(
            colors.OKGREEN + 'Terraform finished! The following resources have been created in AWS.\n' + colors.ENDC)
        call(['terraform', 'state', 'list'], workdir=get_terraform_folder())

        print(
            colors.OKGREEN + 'Use the following values for checking out Jazz.\n' + colors.ENDC)
        call(['terraform', 'output'], workdir=get_terraform_folder())


def exec_terraform_destroy():
    //todo
