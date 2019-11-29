import click
import requests

from retrying import retry
from utils.jenkins import startJobwithInputs, deleteCredential
from utils.api_config import get_config, delete_config


featureName = "MultiAccount"


@click.command()
@click.option(
    "--jenkins_url",
    help='Specify the Jenkins url',
    prompt=True
)
@click.option(
    '--jenkins_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the jenkins separated by a space',
    prompt=True)
@click.option(
    "--jazz_apiendpoint",
    help='Specify the Jazz Endpoint',
    prompt=True
)
@click.option(
    '--jazz_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the jazz application separated by a space',
    prompt=True)
@click.option(
    "--account_details",
    help='Specify the Accounts to delete (Empty will delete all)',
    default='all',
    prompt=True
)
def uninstall(jenkins_url, jenkins_userpass, jazz_apiendpoint, jazz_userpass, account_details):
    click.secho('\n\nThis will remove {0} functionality from your Jazz deployment'.format(featureName), fg='blue')
    jenkins_userpass_list = ''.join(list(jenkins_userpass)).split()
    jenkins_username, jenkins_password = jenkins_userpass_list[0], jenkins_userpass_list[1]
    jazz_userpass_list = ''.join(list(jazz_userpass)).split()
    jazz_username, jazz_password = jazz_userpass_list[0], jazz_userpass_list[1]
    job = "delete-resources"
    startJobwithInputs(jenkins_url, jenkins_username, jenkins_password, job, account_details)
    if jenkins_job_status(job, jenkins_username, jenkins_password, jenkins_url):
        print("Job Executed Successfully")
        get_configjson = get_config(jazz_username, jazz_password, jazz_apiendpoint)
        account_info = get_configjson['data']['config']['AWS']['ACCOUNTS']
        primary_account = get_configjson['data']['config']['AWS']['DEFAULTS']['ACCOUNTID']
        primary_region = get_configjson['data']['config']['AWS']['DEFAULTS']['REGION']
        finalAccounts = []
        if (account_details == "" or account_details == "all"):
            finalAccounts = account_info
        else:
            input_list = [x.strip() for x in account_details.split(',')]
            for awsAccount in account_info:
                accountId = awsAccount['ACCOUNTID']
                if (accountId in input_list):
                    finalAccounts.append(awsAccount)
        if len(finalAccounts) > 0:
            for index, account in enumerate(finalAccounts):
                if account['ACCOUNTID'] != primary_account:
                    print("DELETING - " + account['ACCOUNTID'])
                    query_url = '?path=AWS.ACCOUNTS&id=ACCOUNTID&value=%s' % (account['ACCOUNTID'])
                    delete_config(jazz_username, jazz_password, jazz_apiendpoint, query_url)
                    deleteCredential(jenkins_url, jenkins_username,
                                     jenkins_password, 'MultiAccount' + account['ACCOUNTID'])
                else:
                    allregions = account["REGIONS"]
                    for awsregion in allregions:
                        if awsregion['REGION'] != primary_region:
                            print("DELETING NON PRIMARY REGION:" + awsregion['REGION'] +
                                  " OF ACCOUNT: " + account['ACCOUNTID'])
                            query_url = '?path=AWS.ACCOUNTS.' + str(index) +\
                                        '.REGIONS&id=REGION&value=%s' % (awsregion['REGION'])
                            delete_config(jazz_username, jazz_password, jazz_apiendpoint, query_url)
    else:
        print("Job Execution Failed")


def retry_if_false(result):
    if (result):
        return False
    else:
        return True


@retry(retry_on_result=retry_if_false, wait_random_min=20000, wait_random_max=30000)
def jenkins_job_status(job_name, jenkins_username, jenkins_password, jenkins_url):
    try:
        url = "http://%s:%s@%s/job/%s/lastBuild/api/json" \
                % (jenkins_username, jenkins_password, jenkins_url, job_name)
        data = requests.get(url).json()
        if data['result'] == "SUCCESS":
            return True
        elif data['building']:
            return False
        else:
            raise Exception("Error ! Please contact Administrator...")
    except Exception as e:
        raise Exception(str(e))
