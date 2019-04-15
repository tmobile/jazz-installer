import click
from installer.cli.click_required import Required
from installer.configurators.jenkins import configure_jenkins
from installer.configurators.bitbucket import configure_bitbucket
from installer.configurators.sonarqube import configure_sonarqube
from installer.helpers.terraform import exec_terraform_apply


@click.command()
# TODO Why do we not just accept the full url and strip the port and protocol if we're that picky?
# TODO Why do we ask for all this Jenkins junk for scenario1? We really should just remove Jenkins from scenario 1.
# If you are gonna BYOS you should install plugins and configure it yourself
@click.option(
    '--jenkins_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the existing Jenkins administrator separated by a space',
    prompt=True)
@click.option(
    '--jenkins_endpoint',
    required=True,
    help='Provide the publicly-accessible DNS/IP (without the protocol or port) of the Jenkins server to be configured',
    prompt=True
)
@click.option(
    '--jenkins_sshuser',
    required=True,
    help='Provide the name of a user that can be used to SSH into the Jenkins server to be configured.',
    prompt=True
)
# TODO - (copied todo from old code) This is a temporary fix -
# We need to check why this is needed and should not ask this.
@click.option(
    '--jenkins_secgroup',
    required=True,
    help='Provide the name of the Jenkins security group',
    prompt=True
)
@click.option(
    '--jenkins_subnet',
    required=True,
    help='Provide the subnet for the Jenkins server that is to be configured',
    prompt=True
)
@click.option(
    '--bitbucket_endpoint',
    required=True,
    help='Provide the endpoint (without the protocol or port) of the Bitbucket server to be configured',
    prompt=True
)
@click.option(
    '--bitbucket_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password of the existing Bitbucket administrator separated by a space',
    prompt=True
)
@click.option(
    '--bitbucket_publicip',
    required=True,
    help='Provide the public IP of the Bitbucket server to be configured.',
    prompt=True
)
# Sonarqube (standalone)
@click.option(
    '--sonarqube/--no-sonarqube',
    default=False
)
@click.option(
    '--sonarqube_endpoint',
    help='Provide the endpoint (without the protocol or port) of the Sonarqube server to be configured',
    prompt=True,
    cls=Required,
    required_if='sonarqube'
)
@click.option(
    '--sonarqube_userpass',
    nargs=2,
    cls=Required,
    required_if='sonarqube',
    prompt=True,
    help='Provide the username and password of the existing Sonarqube user separated by a space'
)
@click.option(
    '--sonarqube_publicip',
    cls=Required,
    required_if='sonarqube',
    prompt=True,
    help='Provide the public IP of the Sonarqube server to be configured.'
)
def scenario1(
        # Jenkins inputs
        jenkins_userpass,
        jenkins_endpoint,
        jenkins_sshuser,
        jenkins_secgroup,
        jenkins_subnet,
        # Bitbucket inputs
        bitbucket_endpoint,
        bitbucket_userpass,
        bitbucket_publicip,
        # Sonarqube
        sonarqube,
        sonarqube_endpoint=None,
        sonarqube_userpass=None,
        sonarqube_publicip=None
):
    """Installs stack with preexisting Jenkins and preexisting Bitbucket"""
    # Fix click bug with nargs=2 and prompting
    # https://github.com/pallets/click/issues/532
    jenkins_userpass = ''.join(list(jenkins_userpass)).split()
    click.secho('\n\nConfiguring Jenkins server', fg='blue')
    configure_jenkins(
        jenkins_endpoint,
        jenkins_userpass,
        jenkins_sshuser,
        jenkins_secgroup,
        jenkins_subnet
    )

    click.secho('\n\nConfiguring Bitbucket server', fg='blue')
    # Get Bitbucket configuration details

    # Fix click bug with nargs=2 and prompting
    # https://github.com/pallets/click/issues/532
    bitbucket_userpass = ''.join(list(bitbucket_userpass)).split()
    configure_bitbucket(
        bitbucket_endpoint,
        bitbucket_userpass,
        bitbucket_publicip
    )

    if sonarqube:
        click.secho('\n\nConfiguring Sonarqube server', fg='blue')
        # Get Sonar configuration details
        configure_sonarqube(sonarqube_endpoint, sonarqube_userpass, sonarqube_publicip)

    click.secho('\n\nStarting Terraform', fg='green')
    click.secho('\n\nTerraform output will be echoed here and captured to stack_creation.out', fg='green')

    exec_terraform_apply()
