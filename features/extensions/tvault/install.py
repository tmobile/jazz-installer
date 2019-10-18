import click

from extensions.tvault.terraformBugWorkaround import runTerraform,\
                                                     featureName
from utils.api_config import update_config
from utils.jenkins import setCredential, startJob
from utils.helper import getTerraformOutputVar


featureName = 'Tvault'


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


def install(region, stackprefix, jazz_apiendpoint, jazz_userpass, jenkins_url,
            jenkins_userpass):
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
    # Run terraform first, as we need it's output
    runTerraform(region, stackprefix, jazz_password, True)
