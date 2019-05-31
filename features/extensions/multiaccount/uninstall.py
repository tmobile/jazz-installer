import click
import requests

from retrying import retry
from utils.jenkins import startJobwithInputs


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
