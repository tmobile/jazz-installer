#!/usr/bin/env python2
import json
import os.path
import subprocess
import sys
from collections import OrderedDict

import click

import git_config


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


featureName = "Azure Deployment"
configFolder = "module_config"
jsonConfigFile = 'jazz-installer-vars.json'


@click.group()
def main(**kwargs):
    """This script install Azure deployment ability into a running Jazz platform."""


@main.command()
@click.option('--jazz-stackprefix',
              help='Specify the stackprefix of your existing Jazz installation (e.g. myjazz), your existing config will be imported',
              prompt=True)
@click.option('--scm-repo', help='Specify the scm repo url', prompt=True)
@click.option('--scm-username', help='Specify the scm username', prompt=True)
@click.option('--scm-password', help='Specify the scm password', prompt=True)
@click.option('--scm-pathext', help='Specify the scm repo path ext (Use "scm" for bitbucket)', default="")
@click.option('--azure-subscription-id', help='Specify the ID for the azure subscription to deploy functions into',
              prompt=True)
@click.option('--azure-location', help='Specify the location to install functions', prompt=True)
@click.option('--azure-client-id', help='Specify the client id for the Service Principal used to build infrastructure',
              prompt=True)
@click.option('--azure-client-secret', help='Specify the password for Service Principal', prompt=True)
@click.option('--azure-tenant-id', help='Specify the Azure AD tenant id for the Service Principal', prompt=True)
@click.option('--azure-company-name', help='Specify the company name used in the Azure API Management service',
              prompt=True)
@click.option('--azure-company-email',
              help='Specify the company contact email used in the Azure API Management service', prompt=True)
@click.option('--azure-apim-dev-sku',
              help='The SKU for the Azure API Management service for the development environment', default='Developer',
              show_default='Developer')
@click.option('--azure-apim-stage-sku', help='The SKU for the Azure API Management service for the staging environment',
              default='Developer', show_default='Developer')
@click.option('--azure-apim-prod-sku',
              help='The SKU for the Azure API Management service for the production environment', default='Developer',
              show_default='Developer')
def install(jazz_stackprefix, scm_repo, scm_username, scm_password, scm_pathext,
            azure_subscription_id, azure_location, azure_client_id, azure_client_secret, azure_tenant_id,
            azure_company_name, azure_company_email, azure_apim_dev_sku, azure_apim_stage_sku, azure_apim_prod_sku):
    retrievConfig(scm_repo, scm_username, scm_password, scm_pathext)

    if azureInstalled():
        print("You are attempting to install Azure into a Jazz system that already has Azure installed.\n"
              "If this is an error, please run 'setup.py uninstall' to remove the existing installation")
        sys.exit(1)

    print(
        colors.OKGREEN +
        "\nThis will install {0} functionality into your Jazz deployment.\n".format(featureName)
        + colors.ENDC)
    print(
        colors.OKGREEN +
        "This installer will use whatever AWS credentials you have configured by running 'aws configure'.\n"
        + colors.ENDC)
    print(
        colors.WARNING +
        "Please make sure you are using the same AWS credentials you used to install your Jazz deployment\n\n"
        + colors.ENDC)

    # Run terraform first, as we need it's output
    # todo run terraform for install
    runTerraform(jazz_stackprefix, True)

    updateConfig(azure_subscription_id)

    commitConfig("Adding Azure deployment feature")


@main.command()
@click.option('--jazz-stackprefix',
              help='Specify the stackprefix of your existing Jazz installation (e.g. myjazz), your existing config will be imported',
              prompt=True)
@click.option('--scm-repo', help='Specify the scm repo url', prompt=True)
@click.option('--scm-username', help='Specify the scm username', prompt=True)
@click.option('--scm-password', help='Specify the scm password', prompt=True)
@click.option('--scm-pathext', help='Specify the scm repo path ext (Use "scm" for bitbucket)', default='')
def uninstall(jazz_stackprefix, scm_repo, scm_username, scm_password, scm_pathext):
    retrievConfig(scm_repo, scm_username, scm_password, scm_pathext)

    if not azureInstalled():
        print("Azure is not added to this Jazz installation. Uninstall impossible.")

    print(
        colors.OKGREEN +
        "\nThis will remove {0} functionality from your Jazz deployment.\n".format(featureName)
        + colors.ENDC)

    # todo: run terraform for removal
    terraformStateSanityCheck()
    runTerraform(jazz_stackprefix, False)

    removeConfig()

    commitConfig("Removing Azure deployment feature")


def commitConfig(message):
    git_config.commit_git_config(configFolder, jsonConfigFile, message)


def updateConfig(azure_subscription_id):
    with open("{}/{}".format(configFolder, jsonConfigFile), 'r') as f:
        data = json.load(f, object_pairs_hook=OrderedDict)

    azureConfig = {
        "SUBSCRIPTION_ID": azure_subscription_id,
        "RESOURCE_GROUPS": {
            "DEVELOPMENT": "",  # TODO
            "STAGING": "",  # TODO
            "PRODUCTION": ""  # TODO
        }
    }

    data['AZURE'] = azureConfig

    with open("{}/{}".format(configFolder, jsonConfigFile), 'w') as f:
        json.dump(data, f, indent=4)


def removeConfig():
    with open("{}/{}".format(configFolder, jsonConfigFile), 'r') as f:
        data = json.load(f, object_pairs_hook=OrderedDict)
    data.pop('AZURE', None)
    with open("{}/{}".format(configFolder, jsonConfigFile), 'w') as f:
        json.dump(data, f, indent=4)


def retrievConfig(scm_repo, scm_username, scm_password, scm_pathext):
    subprocess.check_call(["rm", "-rf", configFolder])
    git_config.clone_git_config_repo(scm_repo, scm_username, scm_password, scm_pathext, configFolder)


def azureInstalled():
    with open(configFolder + '/' + jsonConfigFile, 'r') as f:
        installData = json.load(f)
    return 'AZURE' in installData


def terraformStateSanityCheck():
    print(colors.OKBLUE +
          'Making sure you have not deleted the Terraform .tfstate file...' +
          colors.ENDC)
    if not os.path.isfile('./terraform/terraform.tfstate'):
        print(colors.FAIL +
              'Cannot find the Terraform .tfstate file! No uninstall possible'
              + colors.ENDC)


def runTerraform(envPrefix, install):
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='./terraform')

    subprocess.check_call(
        [
            'terraform', 'apply' if install else 'destroy', '-auto-approve',
            '-var', 'env_prefix={0}'.format(envPrefix),
        ],
        cwd='./terraform')


def getTerraformOutputVar(varname):
    try:
        return subprocess.check_output(
            ['terraform', 'output', varname],
            cwd='./terraform')
    except subprocess.CalledProcessError:
        print("Failed getting output variable {0} from terraform!".format(varname))
        sys.exit()

main()
