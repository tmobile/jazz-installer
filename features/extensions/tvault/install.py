import click
import json
import re
from collections import OrderedDict
from extensions.tvault.terraformBugWorkaround import runTerraform,\
                                                     featureName
from utils.api_config import update_config
from utils.jenkins import setCredential, startJob
from utils.helper import getTerraformOutputVar


@click.command()
@click.option(
    "--region",
    "-r",
    help='Specify the region where your Jazz installation lives',
    type=click.Choice(['us-east-1', 'us-west-2']),
    default='us-east-1'
)
@click.option(
    "--stackprefix",
    "-p",
    help='Specify the stackprefix of your existing Jazz installation (e.g. myjazz), \
          your existing config will be imported',
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
@click.option(
    "--network_range",
    help='Specify the Network Range',
    prompt=True
)
def install(region, stackprefix, jazz_apiendpoint, jazz_userpass, jenkins_url,
            jenkins_userpass, network_range):
    click.secho('\n\nThis will install {0} functionality into your Jazz \
                deployment'.format(featureName), fg='blue')
    click.secho('\nThis installer will use whatever AWS credentials you have configured by \
                running `aws configure`', fg='green')
    click.secho('\nPlease make sure you are using the same AWS credentials you used to \
                install your Jazz deployment', fg='green')
    jazz_userpass_list = ''.join(list(jazz_userpass)).split()
    jazz_username, jazz_password = jazz_userpass_list[0], jazz_userpass_list[1]
    jenkins_userpass_list = ''.join(list(jenkins_userpass)).split()
    jenkins_username, jenkins_password = jenkins_userpass_list[0], jenkins_userpass_list[1]
    tvault_username = re.sub('[^a-zA-Z0-9_-]', '-', jazz_username)
    # Run terraform first, as we need it's output
    runTerraform(region, stackprefix, jazz_password, tvault_username, True, network_range)
    # Store the CREDENTIAL_ID in jenkins
    setCredential(jenkins_url, jenkins_username, jenkins_password, "TVAULT_ADMIN",
                  "safeadmin", jazz_password)
    update_config(
        "TVAULT",
        prepare_tvault_json(),
        jazz_username,
        jazz_password,
        jazz_apiendpoint
    )
    # Trigger tvault api
    tvaultJobUrl = "job/build-pack-api/buildWithParameters?token=jazz-101-job&service_name=t-vault&domain" \
                   "=jazz&scm_branch=master"
    startJob(jenkins_url, jenkins_username, jenkins_password, tvaultJobUrl)
    # Trigger jazz ui
    startJob(jenkins_url, jenkins_username, jenkins_password, "job/jazz_ui/buildWithParameters?token=jazz-101-job")


def prepare_tvault_json():
    extension_base = "extensions/tvault"
    tvaultConfig = OrderedDict()
    tvaultConfig['IS_ENABLED'] = True
    tvaultConfig['HOSTNAME'] = getTerraformOutputVar("tvault-host", extension_base)
    tvaultConfig['CREDENTIAL_ID'] = "TVAULT_ADMIN"
    return json.loads(json.dumps(tvaultConfig))
