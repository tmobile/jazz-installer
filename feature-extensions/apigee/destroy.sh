#!/usr/bin/env python2
import subprocess
import os.path

class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def main():
    print(
        colors.OKGREEN +
        "\nThis will remove Apigee functionality from your Jazz deployment.\n"
        + colors.ENDC)
    runTerraform()


def terraformStateSanityCheck():
    print(colors.OKBLUE + 'Making sure you have not deleted the Terraform .tfstate file...' + colors.ENDC)
    if not os.path.isfile('./terraform/terraform.tfstate'):
        print(colors.FAIL + 'Cannot find the Terraform .tfstate file! No uninstall possible' + colors.ENDC)

def runTerraform():
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'destroy', '-auto-approve'], cwd='./terraform')


main()
