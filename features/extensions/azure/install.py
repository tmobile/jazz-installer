import click

from utils.api_config import update_config
from utils.jenkins import setCredential, startJob
from utils.helper import azure_installed


featureName = "Azure"


@click.command()
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
    click.secho('\n\nThis will install {0} functionality into your Jazz deployment'.format(featureName), fg='blue')
    if azure_installed():
        print("You are attempting to install Azure into a Jazz system that already has Azure installed.\n"
              "If this is an error, please run 'setup.py uninstall' to remove the existing installation")
        sys.exit(1)
    click.secho('\nThis installer will use whatever AWS credentials you have configured by \
                running `aws configure`', fg='green')
    click.secho('\nPlease make sure you are using the same AWS credentials you used to \
                install your Jazz deployment', fg='green')
                
