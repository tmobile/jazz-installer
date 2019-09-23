import click
import sys


from utils.api_config import update_config
from utils.helper import azure_installed, terraformStateSanityCheck
from extensions.azure.terraformHelper import destroy_terraform


featureName = "Azure"


@click.command()
@click.option('--jazz-stackprefix',
              envvar='JAZZ_STACKPREFIX',
              help='Stackprefix of your Jazz installation (e.g. myjazz), your existing config will be imported',
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
def uninstall(jazz_stackprefix, jazz_apiendpoint, jazz_username, jazz_password, azure_subscription_id,
              azure_location, azure_client_id, azure_client_secret, azure_tenant_id, azure_company_name,
              azure_company_email):
    if not azure_installed(jazz_username, jazz_password, jazz_apiendpoint):
        print("Azure is not added to this Jazz installation. Uninstall impossible.")
        sys.exit(1)

    click.secho('\n\nThis will remove {0} functionality from your Jazz deployment'.format(featureName), fg='blue')
    terraformStateSanityCheck("extensions/azure")
    destroy_terraform(jazz_stackprefix, azure_location, azure_subscription_id, azure_client_id, azure_client_secret,
                      azure_tenant_id, azure_company_name, azure_company_email)
    update_config(
        "AZURE",
        {},
        jazz_username,
        jazz_password,
        jazz_apiendpoint
    )
