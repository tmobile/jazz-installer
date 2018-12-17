import click
from installer.configurators.jenkins_container import configure_jenkins_container
from installer.configurators.bitbucket import configure_bitbucket
from installer.configurators.sonarqube_container import configure_sonarqube_container
from installer.helpers.terraform import exec_terraform_apply


@click.command()
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
# Sonarqube (container)
@click.option(
    '--sonarqube/--no-sonarqube',
    default=False
)
def scenario2(bitbucket_endpoint, bitbucket_userpass, bitbucket_publicip, sonarqube):
    """Installs stack with containerized Jenkins and preexisting Bitbucket"""

    click.secho('\n\nConfiguring Jenkins server', fg='blue')
    configure_jenkins_container()

    click.secho('\n\nConfiguring Bitbucket server', fg='blue')
    # Get Bitbucket configuration details
    configure_bitbucket(
        bitbucket_endpoint,
        bitbucket_userpass,
        bitbucket_publicip
    )

    if sonarqube:
        click.secho('\n\nConfiguring Sonarqube server', fg='blue')
        configure_sonarqube_container()

    click.secho('\n\nStarting Terraform', fg='green')
    click.secho('\n\nTerraform output will be echoed here and captured to stack_creation.out', fg='green')

    exec_terraform_apply()
