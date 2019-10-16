import click
import json
import sys
from collections import OrderedDict

from utils.api_config import update_config
from utils.jenkins import setCredential, startJob
from utils.helper import azure_installed, getTerraformOutputVar
from extensions.azure.terraformHelper import apply_terraform

featureName = "Azure"


@click.command()
@click.option('--jazz-stackprefix',
              envvar='JAZZ_STACKPREFIX',
              help='Stackprefix of your Jazz installation (e.g. myjazz), your existing config will be imported',
              prompt=True)
@click.option('--jenkins-url', envvar='JENKINS_URL', help='Specify the url of the Jenkins install', prompt=True)
@click.option('--jenkins-user', envvar='JENKINS_USER', help='Admin username for configuration changes', prompt=True)
@click.option('--jenkins-api-token', envvar='JENKINS_API_TOKEN', help='Admin API token for configuration changes',
              prompt=True)
@click.option('--jazz-apiendpoint', envvar='JAZZ_APIENDPOINT', help='Specify the Jazz Endpoint', prompt=True)
@click.option('--jazz-username', envvar='JAZZ_USERNAME', help='Specify the Jazz Admin username', prompt=True)
@click.option('--jazz-password', envvar='JAZZ_PASSWORD', help='Specify the Jazz Admin password',
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
def install(jazz_stackprefix, jenkins_url, jenkins_user, jenkins_api_token, jazz_apiendpoint, jazz_username,
            jazz_password, azure_subscription_id, azure_location, azure_client_id, azure_client_secret,
            azure_tenant_id, azure_company_name, azure_company_email, azure_apim_dev_sku,
            azure_apim_stage_sku, azure_apim_prod_sku):
    click.secho('\n\nThis will install {0} functionality into your Jazz deployment'.format(featureName), fg='blue')
    if azure_installed(jazz_username, jazz_password, jazz_apiendpoint):
        print("You are attempting to install Azure into a Jazz system that already has Azure installed.\n"
              "If this is an error, please run 'setup.py uninstall' to remove the existing installation")
        sys.exit(1)
    click.secho('\nThis installer will use whatever AWS credentials you have configured by \
                running `aws configure`', fg='green')
    click.secho('\nPlease make sure you are using the same AWS credentials you used to \
                install your Jazz deployment', fg='green')

    # Run terraform first, as we need it's output
    apply_terraform(jazz_stackprefix, azure_location, azure_subscription_id, azure_client_id, azure_client_secret,
                    azure_tenant_id, azure_company_name, azure_company_email, azure_apim_dev_sku, azure_apim_stage_sku,
                    azure_apim_prod_sku)
    azure_json = prepare_azure_json(azure_location, azure_subscription_id)
    update_config(
        "AZURE",
        azure_json,
        jazz_username,
        jazz_password,
        jazz_apiendpoint
    )
    for creds in [{"id": 'AZ_CLIENTID', "value": azure_client_id},
                  {"id": 'AZ_PASSWORD', "value": azure_client_secret},
                  {"id": 'AZ_SUBSCRIPTIONID', "value": azure_subscription_id},
                  {"id": 'AZ_TENANTID', "value": azure_tenant_id}]:
        setCredential(jenkins_url, jenkins_user, jenkins_api_token, creds['id'],
                      creds['id'], creds['value'])

    # Trigger create-serverless-service api
    createSSJobUrl = "job/build-pack-api/buildWithParameters?token=jazz-101-job&service_name" \
                     "=create-serverless-service&domain=jazz&scm_branch=master"
    startJob(jenkins_url, jenkins_user, jenkins_api_token, createSSJobUrl)
    # Trigger metrics api
    metricJobUrl = "job/build-pack-api/buildWithParameters?token=jazz-101-job&service_name=metrics&domain" \
                   "=jazz&scm_branch=master"
    startJob(jenkins_url, jenkins_user, jenkins_api_token, metricJobUrl)
    # Trigger jazz ui
    startJob(jenkins_url, jenkins_user, jenkins_api_token, "job/jazz_ui/buildWithParameters?token=jazz-101-job")


def prepare_azure_json(azure_location, azure_subscription_id):
    extension_base = "extensions/azure"
    azureConfig = OrderedDict()
    azureConfig['IS_ENABLED'] = True
    azureAccount = OrderedDict()
    azureAccount['ACCOUNTID'] = azure_subscription_id
    azureAccount['ACCOUNTNAME'] = 'azureaccount'
    azureAccount['SUBSCRIPTION_ID'] = 'AZ_SUBSCRIPTIONID'
    azureAccount['CLIENT_ID'] = 'AZ_CLIENTID'
    azureAccount["PASSWORD"] = 'AZ_PASSWORD'
    azureAccount["TENANT_ID"] = 'AZ_TENANTID'
    azureRegions = OrderedDict()
    azureRegions['LOCATION'] = azure_location
    azureRegions['REGION'] = azure_location.lower().replace(' ', '')
    azureRegions['RESOURCE_GROUPS'] = OrderedDict()
    azureRegions['RESOURCE_GROUPS']['DEV'] = getTerraformOutputVar("dev_resource_group", extension_base)
    azureRegions['RESOURCE_GROUPS']['PROD'] = getTerraformOutputVar("prod_resource_group", extension_base)
    azureRegions['RESOURCE_GROUPS']['STG'] = getTerraformOutputVar("stage_resource_group", extension_base)
    azureRegions['APIM'] = OrderedDict()
    azureRegions['APIM']['DEV'] = getTerraformOutputVar("dev_apim", extension_base)
    azureRegions['APIM']['PROD'] = getTerraformOutputVar("prod_apim", extension_base)
    azureRegions['APIM']['STG'] = getTerraformOutputVar("stage_apim", extension_base)
    azureAccount['REGIONS'] = [azureRegions]
    azureConfig['ACCOUNTS'] = [azureAccount]
    azureDefault = OrderedDict()
    azureDefault['ACCOUNTID'] = azure_subscription_id
    azureDefault['PROVIDER'] = 'azure'
    azureDefault['REGION'] = azure_location.lower().replace(' ', '')
    azureConfig['DEFAULTS'] = azureDefault
    return json.loads(json.dumps(azureConfig))
