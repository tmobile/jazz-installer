import sys

import requests
from requests.auth import HTTPBasicAuth


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
    basic_auth = HTTPBasicAuth(jenkins_user, jenkins_api_token)

    add_jenkins_credential(jenkins_host, jenkins_port, basic_auth, 'AZ_CLIENTID', azure_client_id)
    add_jenkins_credential(jenkins_host, jenkins_port, basic_auth, 'AZ_PASSWORD', azure_client_secret)
    add_jenkins_credential(jenkins_host, jenkins_port, basic_auth, 'AZ_SUBSCRIPTIONID', azure_subscription_id)
    add_jenkins_credential(jenkins_host, jenkins_port, basic_auth, 'AZ_TENANTID', azure_tenant_id)


def add_jenkins_credential(jenkins_host, jenkins_port, basic_auth, key, value):
    url = "http://{}:{}/credentials/store/system/domain/_/createCredentials".format(jenkins_host,
                                                                                    jenkins_port)
    content = ("{{\n"
               "  \"\": \"0\",\n"
               "  \"credentials\": {{\n"
               "    \"scope\": \"GLOBAL\",\n"
               "    \"id\": \"{0}\",\n"
               "    \"username\": \"{0}\",\n"
               "    \"password\": \"{1}\",\n"
               "    \"description\": \"{0}\",\n"
               "    \"$class\": \"com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl\"\n"
               "  }}\n"
               "}}").format(key, value)
    data = {'json': content}
    resp = requests.post(url, data=data, auth=basic_auth)
    if resp.status_code != 200:
        print(colors.FAIL +
              "Failed to add {0} credential to jenkins. Response code: {1}".format(key, resp.status_code)
              + colors.ENDC)
        sys.exit(1)
