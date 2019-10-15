import click

from extensions.apigee.terraformBugWorkaround import runTerraform,\
                                                     restoreOldRoleToExistingFunctionWithCLI,\
                                                     featureName,\
                                                     gatewayFunctionName
from utils.api_config import update_config
from utils.jenkins import startJob
from utils.helper import terraformStateSanityCheck


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
    '--jazz_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the jazz application separated by a space',
    prompt=True)
@click.option(
    "--jazz_apiendpoint",
    help='Specify the Jazz Endpoint',
    prompt=True
)
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
def uninstall(region, stackprefix, jazz_userpass, jazz_apiendpoint, jenkins_url, jenkins_userpass):
    click.secho('\n\nThis will remove {0} functionality from your Jazz deployment'.format(featureName), fg='blue')
    terraformStateSanityCheck("extensions/apigee")

    # TODO remove this entire module when the terraform bug is fixed
    click.secho('\nRestoring old role to gateway function', fg='blue')

    # Restore old role first, before we destroy the Terraform resources
    restoreOldRoleToExistingFunctionWithCLI(stackprefix + "-" + gatewayFunctionName)
    jazz_userpass_list = ''.join(list(jazz_userpass)).split()
    jazz_username, jazz_password = jazz_userpass_list[0], jazz_userpass_list[1]
    jenkins_userpass_list = ''.join(list(jenkins_userpass)).split()
    jenkins_username, jenkins_password = jenkins_userpass_list[0], jenkins_userpass_list[1]
    runTerraform(region, stackprefix, False)
    update_config(
        "APIGEE.ENABLE_APIGEE",
        'false',
        jazz_username,
        jazz_password,
        jazz_apiendpoint
    )
    # Trigger metrics api
    metricJobUrl = "job/build-pack-api/buildWithParameters?token=jazz-101-job&service_name=metrics&domain" \
                   "=jazz&scm_branch=master"
    startJob(jenkins_url, jenkins_username, jenkins_password, metricJobUrl)
    # Trigger jazz ui
    startJob(jenkins_url, jenkins_username, jenkins_password, "job/jazz_ui/buildWithParameters?token=jazz-101-job")
