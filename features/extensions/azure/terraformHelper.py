import subprocess
from utils.helper import colors


def apply_terraform(jazzprefix, azure_location, azure_subscription_id, azure_client_id, azure_client_secret,
                    azure_tenant_id, azure_company_name, azure_company_email, azure_apim_dev_sku, azure_apim_stage_sku,
                    azure_apim_prod_sku):
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='extensions/azure/terraform')

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
        cwd='extensions/azure/terraform')


def destroy_terraform(jazzprefix, azure_location, azure_subscription_id, azure_client_id, azure_client_secret,
                      azure_tenant_id, azure_company_name, azure_company_email):
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='extensions/azure/terraform')

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
        cwd='extensions/azure/terraform')
