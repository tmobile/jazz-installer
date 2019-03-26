#!/usr/bin/env python2
import json
import os.path
import subprocess
import sys
from collections import OrderedDict

import click

import git_config
import jenkins_config


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
              envvar='JAZZ_STACKPREFIX',
              help='Stackprefix of your Jazz installation (e.g. myjazz), your existing config will be imported',
              prompt=True)
@click.option('--scm-repo', envvar='SCM_REPO', help='Specify the scm repo url', prompt=True)
@click.option('--scm-username', envvar='SCM_USERNAME', help='Specify the scm username', prompt=True)
@click.option('--scm-password', envvar='SCM_PASSWORD', help='Specify the scm password', prompt=True)
@click.option('--scm-pathext', envvar='SCM_PATHEXT', help='Specify the scm repo path ext (Use "scm" for bitbucket)',
              default="")
@click.option('--jenkins-host', envvar='JENKINS_HOST', help='Specify the host of the Jenkins install', prompt=True)
@click.option('--jenkins-port', envvar='JENKINS_PORT', help='Specify the port of the Jenkins install', prompt=True)
@click.option('--jenkins-user', envvar='JENKINS_USER', help='Admin username for configuration changes', prompt=True)
@click.option('--jenkins-api-token', envvar='JENKINS_API_TOKEN', help='Admin API token for configuration changes',
              prompt=True)
@click.option('--azure-subscription-id', envvar='AZURE_SUBSCRIPTION_ID',
              help='Specify the ID for the azure subscription to deploy functions into',
              prompt=True)
@click.option('--azure-location', envvar='AZURE_LOCATION', help='Specify the location to install functions',
              prompt=True)
@click.option('--azure-client-id', envvar='AZURE_CLIENT_ID',
              help='Specify the client id for the Service Principal used to build infrastructure',
              prompt=True)
@click.option('--azure-client-secret', envvar='AZURE_CLIENT_SECRET', help='Specify the password for Service Principal',
              prompt=True)
@click.option('--azure-tenant-id', envvar='AZURE_TENANT_ID',
              help='Specify the Azure AD tenant id for the Service Principal', prompt=True)
@click.option('--azure-company-name', envvar='AZURE_COMPANY_NAME',
              help='Specify the company name used in the Azure API Management service',
              prompt=True)
@click.option('--azure-company-email', envvar='AZURE_COMPANY_EMAIL',
              help='Specify the company contact email used in the Azure API Management service', prompt=True)
@click.option('--azure-apim-dev-sku', envvar='AZURE_APIM_DEV_SKU',
              help='The SKU for the Azure API Management service for the development environment', default='Developer',
              show_default='Developer')
@click.option('--azure-apim-stage-sku', envvar='AZURE_APIM_STAGE_SKU',
              help='The SKU for the Azure API Management service for the staging environment',
              default='Developer', show_default='Developer')
@click.option('--azure-apim-prod-sku', envvar='AZURE_APIM_PROD_SKU',
              help='The SKU for the Azure API Management service for the production environment', default='Developer',
              show_default='Developer')
def install(jazz_stackprefix, scm_repo, scm_username, scm_password, scm_pathext, jenkins_host, jenkins_port,
            jenkins_user,
            jenkins_api_token, azure_subscription_id, azure_location, azure_client_id, azure_client_secret,
            azure_tenant_id, azure_company_name, azure_company_email, azure_apim_dev_sku, azure_apim_stage_sku,
            azure_apim_prod_sku):
    retrieve_config(scm_repo, scm_username, scm_password, scm_pathext)

    if azure_installed():
        print("You are attempting to install Azure into a Jazz system that already has Azure installed.\n"
              "If this is an error, please run 'setup.py uninstall' to remove the existing installation")
        sys.exit(1)

    print(colors.OKGREEN +
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
    apply_terraform(jazz_stackprefix, azure_location, azure_subscription_id, azure_client_id, azure_client_secret,
                    azure_tenant_id, azure_company_name, azure_company_email, azure_apim_dev_sku, azure_apim_stage_sku,
                    azure_apim_prod_sku)

    update_config(azure_subscription_id, azure_location, azure_client_id, azure_client_secret, azure_tenant_id)
    jenkins_config.update_jenkins(jenkins_user, jenkins_host, jenkins_port, jenkins_api_token, azure_client_id,
                                  azure_client_secret,
                                  azure_tenant_id, azure_subscription_id)
    commit_config("Adding Azure deployment feature")


@main.command()
@click.option('--jazz-stackprefix',
              envvar='JAZZ_STACKPREFIX',
              help='Stackprefix of your Jazz installation (e.g. myjazz), your existing config will be imported',
              prompt=True)
@click.option('--scm-repo', envvar='SCM_REPO', help='Specify the scm repo url', prompt=True)
@click.option('--scm-username', envvar='SCM_USERNAME', help='Specify the scm username', prompt=True)
@click.option('--scm-password', envvar='SCM_PASSWORD', help='Specify the scm password', prompt=True)
@click.option('--scm-pathext', envvar='SCM_PATHEXT', help='Specify the scm repo path ext (Use "scm" for bitbucket)',
              default='')
@click.option('--azure-subscription-id', envvar='AZURE_SUBSCRIPTION_ID',
              help='Specify the ID for the azure subscription to deploy functions into',
              prompt=True)
@click.option('--azure-location', envvar='AZURE_LOCATION', help='Specify the location to install functions',
              prompt=True)
@click.option('--azure-client-id', envvar='AZURE_CLIENT_ID',
              help='Specify the client id for the Service Principal used to build infrastructure',
              prompt=True)
@click.option('--azure-client-secret', envvar='AZURE_CLIENT_SECRET', help='Specify the password for Service Principal',
              prompt=True)
@click.option('--azure-tenant-id', envvar='AZURE_TENANT_ID',
              help='Specify the Azure AD tenant id for the Service Principal', prompt=True)
@click.option('--azure-company-name', envvar='AZURE_COMPANY_NAME',
              help='Specify the company name used in the Azure API Management service',
              prompt=True)
@click.option('--azure-company-email', envvar='AZURE_COMPANY_EMAIL',
              help='Specify the company contact email used in the Azure API Management service', prompt=True)
def uninstall(jazz_stackprefix, scm_repo, scm_username, scm_password, scm_pathext, azure_subscription_id,
              azure_location, azure_client_id, azure_client_secret, azure_tenant_id, azure_company_name,
              azure_company_email):
    retrieve_config(scm_repo, scm_username, scm_password, scm_pathext)

    if not azure_installed():
        print("Azure is not added to this Jazz installation. Uninstall impossible.")

    print(
        colors.OKGREEN +
        "\nThis will remove {0} functionality from your Jazz deployment.\n".format(featureName)
        + colors.ENDC)

    terraform_state_sanity_check()
    destroy_terraform(jazz_stackprefix, azure_location, azure_subscription_id, azure_client_id, azure_client_secret,
                      azure_tenant_id, azure_company_name, azure_company_email)

    remove_config()
    commit_config("Removing Azure deployment feature")


def commit_config(message):
    git_config.commit_git_config(configFolder, jsonConfigFile, message)


def update_config(azure_subscription_id, azure_location, azure_client_id, azure_client_secret, azure_tenant_id):
    with open("{}/{}".format(configFolder, jsonConfigFile), 'r') as f:
        data = json.load(f, object_pairs_hook=OrderedDict)

    azureConfig = OrderedDict()
    azureConfig['IS_ENABLED'] = True
    azureConfig['SUBSCRIPTION_ID'] = 'AZ_SUBSCRIPTIONID'
    azureConfig['CLIENT_ID'] = 'AZ_CLIENTID'
    azureConfig["PASSWORD"] = 'AZ_PASSWORD'
    azureConfig["TENANT_ID"] = 'AZ_TENANTID'
    azureConfig['LOCATION'] = azure_location
    azureConfig['RESOURCE_GROUPS'] = OrderedDict()
    azureConfig['RESOURCE_GROUPS']['DEVELOPMENT'] = getTerraformOutputVar("dev_resource_group")
    azureConfig['RESOURCE_GROUPS']['STAGING'] = getTerraformOutputVar("stage_resource_group")
    azureConfig['RESOURCE_GROUPS']['PRODUCTION'] = getTerraformOutputVar("prod_resource_group")
    azureConfig['APIM'] = OrderedDict()
    azureConfig['APIM']['DEVELOPMENT'] = getTerraformOutputVar("dev_apim")
    azureConfig['APIM']['STAGING'] = getTerraformOutputVar("stage_apim")
    azureConfig['APIM']['PRODUCTION'] = getTerraformOutputVar("prod_apim")

    data['AZURE'] = azureConfig

    with open("{}/{}".format(configFolder, jsonConfigFile), 'w') as f:
        json.dump(data, f, indent=4)


def remove_config():
    with open("{}/{}".format(configFolder, jsonConfigFile), 'r') as f:
        data = json.load(f, object_pairs_hook=OrderedDict)
    data.pop('AZURE', None)
    with open("{}/{}".format(configFolder, jsonConfigFile), 'w') as f:
        json.dump(data, f, indent=4)


def retrieve_config(scm_repo, scm_username, scm_password, scm_pathext):
    subprocess.check_call(["rm", "-rf", configFolder])
    git_config.clone_git_config_repo(scm_repo, scm_username, scm_password, scm_pathext, configFolder)


def azure_installed():
    with open(configFolder + '/' + jsonConfigFile, 'r') as f:
        installData = json.load(f)
    return 'AZURE' in installData


def terraform_state_sanity_check():
    print(colors.OKBLUE +
          'Making sure you have not deleted the Terraform .tfstate file...' +
          colors.ENDC)
    if not os.path.isfile('./terraform/terraform.tfstate'):
        print(colors.FAIL +
              'Cannot find the Terraform .tfstate file! No uninstall possible'
              + colors.ENDC)


def apply_terraform(jazzprefix, azure_location, azure_subscription_id, azure_client_id, azure_client_secret,
                    azure_tenant_id, azure_company_name, azure_company_email, azure_apim_dev_sku, azure_apim_stage_sku,
                    azure_apim_prod_sku):
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='./terraform')

    subprocess.check_call(
        [
            'terraform', 'apply', '-auto-approve',
            '-var', 'jazzprefix={0}'.format(jazzprefix),
            '-var', 'location={0}'.format(azure_location),
            '-var', 'subscription_id={0}'.format(azure_subscription_id),
            '-var', 'client_id={0}'.format(azure_client_id),
            '-var', 'client_secret={0}'.format(azure_client_secret),
            '-var', 'tenant_id={0}'.format(azure_tenant_id),
            '-var', 'company_name={0}'.format(azure_company_name),
            '-var', 'company_email={0}'.format(azure_company_email),
            '-var', 'apim_dev_sku={0}'.format(azure_apim_dev_sku),
            '-var', 'apim_stage_sku={0}'.format(azure_apim_stage_sku),
            '-var', 'apim_prod_sku={0}'.format(azure_apim_prod_sku),
        ],
        cwd='./terraform')


def destroy_terraform(jazzprefix, azure_location, azure_subscription_id, azure_client_id, azure_client_secret,
                      azure_tenant_id, azure_company_name, azure_company_email):
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='./terraform')

    subprocess.check_call(
        [
            'terraform', 'destroy', '-auto-approve',
            '-var', 'jazzprefix={0}'.format(jazzprefix),
            '-var', 'location={0}'.format(azure_location),
            '-var', 'subscription_id={0}'.format(azure_subscription_id),
            '-var', 'client_id={0}'.format(azure_client_id),
            '-var', 'client_secret={0}'.format(azure_client_secret),
            '-var', 'tenant_id={0}'.format(azure_tenant_id),
            '-var', 'company_name={0}'.format(azure_company_name),
            '-var', 'company_email={0}'.format(azure_company_email),
        ],
        cwd='./terraform')


def getTerraformOutputVar(varname):
    try:
        return subprocess.check_output(['terraform', 'output', varname], cwd='./terraform').strip(' \n\r')
    except subprocess.CalledProcessError:
        print("Failed getting output variable {0} from terraform!".format(varname))
        sys.exit()


main()
