import click

from utils.api_config import update_config
from utils.jenkins import setCredential, startJob
from extensions.multiaccount.core import deploy_core_service


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
                      aws_accesskey, aws_secretkey, "aws")
        update_config(
            "AWS.ACCOUNTS",
            account_json,
            jazz_username,
            jazz_password,
            jazz_apiendpoint
        )
    # Trigger jazz ui
    startJob(jenkins_url, jenkins_username, jenkins_password, "job/jazz_ui/buildWithParameters?token=jazz-101-job")
