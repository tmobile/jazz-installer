import os
import subprocess
import sys
from utils.api_config import get_config


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def azure_installed(jazz_username, jazz_password, jazz_apiendpoint):
    get_configjson = get_config(jazz_username, jazz_password, jazz_apiendpoint)
    return get_configjson['data']['config']['AZURE']['IS_ENABLED']


def terraformStateSanityCheck(directory):
    print(colors.OKBLUE +
          'Making sure you have not deleted the Terraform .tfstate file...' +
          colors.ENDC)
    if not os.path.isfile(directory+'/terraform/terraform.tfstate'):
        print(colors.FAIL +
              'Cannot find the Terraform .tfstate file! No uninstall possible'
              + colors.ENDC)


def getTerraformOutputVar(varname, directory):
    try:
        return subprocess.check_output(
            ['terraform', 'output', varname],
            cwd=directory+'/terraform', encoding='UTF-8').rstrip()
    except subprocess.CalledProcessError:
        print("Failed getting output variable {0} from terraform!".format(varname))
        sys.exit()
