import click
import requests

from retrying import retry
from utils.api_config import update_config
from utils.jenkins import setCredential, startJob, startJobwithInputs
from extensions.multiaccount.core import deploy_core_service


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


featureName = "MultiAccount"


@click.command()
@click.option(
    "--regions",
    "-r",
    help=('Specify AWS regions you wish to apply on the new account'),
    required=True,
    multiple=True
)
@click.option(
    "--stackprefix",
    "-p",
    help='Specify the stackprefix of your existing Jazz installation (e.g. myjazz), \
          your existing config will be imported',
    prompt=True
)
@click.option(
    "--aws_accesskey",
    help='AWS accesskey of the new account',
    prompt=True
)
@click.option(
    "--aws_secretkey",
    help='AWS secretkey of the new account',
    prompt=True
)
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
def install(regions, stackprefix, aws_accesskey, aws_secretkey, jazz_apiendpoint,
            jazz_userpass, jenkins_url, jenkins_userpass):
    click.secho('\n\nThis will install {0} functionality into your Jazz deployment'.format(featureName), fg='blue')
    tags = [{
                'Key': 'Name',
                'Value': stackprefix
            },
            {
                'Key': 'Application',
                'Value': 'Jazz'
            },
            {
                'Key': 'JazzInstance',
                'Value': stackprefix
            }]
    regions_list = ' '.join(list(regions)).split()
    jazz_userpass_list = ''.join(list(jazz_userpass)).split()
    jazz_username, jazz_password = jazz_userpass_list[0], jazz_userpass_list[1]
    jenkins_userpass_list = ''.join(list(jenkins_userpass)).split()
    jenkins_username, jenkins_password = jenkins_userpass_list[0], jenkins_userpass_list[1]
    account_json, credential_id = deploy_core_service(aws_accesskey, aws_secretkey, jazz_username, jazz_password,
                                                      jazz_apiendpoint, regions_list, stackprefix, tags)
    if account_json != '':
        # Store the CREDENTIAL_ID in jenkins
        setCredential(jenkins_url, jenkins_username, jenkins_password, credential_id,
                      aws_accesskey, aws_secretkey, "awskey_cred.sh")
        update_config(
            "AWS.ACCOUNTS",
            account_json,
            jazz_username,
            jazz_password,
            jazz_apiendpoint
        )
    # Trigger jazz ui
    startJob(jenkins_url, jenkins_username, jenkins_password, "job/jazz_ui/build?token=jazz-101-job")


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
    "--account_details",
    help='Specify the Accounts to delete (Empty will delete all)',
    default='all',
    prompt=True
)
def uninstall(jenkins_url, jenkins_userpass, account_details):
    click.secho('\n\nThis will remove {0} functionality from your Jazz deployment'.format(featureName), fg='blue')
    jenkins_userpass_list = ''.join(list(jenkins_userpass)).split()
    jenkins_username, jenkins_password = jenkins_userpass_list[0], jenkins_userpass_list[1]
    job = "delete-resources"
    startJobwithInputs(jenkins_url, jenkins_username, jenkins_password, job, account_details)
    if jenkins_job_status(job, jenkins_username, jenkins_password, jenkins_url):
        print("Job Executed Successfully")
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
