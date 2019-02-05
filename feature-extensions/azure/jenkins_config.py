import requests
import sys

class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def update_jenkins(jenkins_user, jenkins_host, jenkins_port, jenkins_api_token, azure_client_id, azure_client_secret,
                   azure_tenant_id, azure_subscription_id):
    credential_url = "http://{}:{}@{}:{}/credentials/store/system/domain/_/createCredentials".format(jenkins_user,
                                                                                                     jenkins_api_token,
                                                                                                     jenkins_host,
                                                                                                     jenkins_port)
    add_jenkins_credential(credential_url, 'AZ_CLIENTID', azure_client_id)
    add_jenkins_credential(credential_url, 'AZ_PASSWORD', azure_client_secret)
    add_jenkins_credential(credential_url, 'AZ_SUBSCRIPTIONID', azure_subscription_id)
    add_jenkins_credential(credential_url, 'AZ_TENANTID', azure_tenant_id)


def add_jenkins_credential(credential_url, key, value):
    content = """{{
  "": "0",
  "credentials": {{
    "scope": "GLOBAL",
    "id": "{0}",
    "username": "{0}",
    "password": "{1}",
    "description": "{0}",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }}
}}""".format(key, value)
    data = {'json': content }
    resp = requests.post(credential_url, data)
    if resp.status_code != 200:
        print(colors.FAIL +
              "Failed to add {0} credential to jenkins. Response code: {1}".format(key, resp.status_code)
              + colors.ENDC)
        sys.exit(1)
