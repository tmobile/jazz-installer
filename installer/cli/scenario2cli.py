import click
from installer.cli.click_required import Required
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
    help='Provide the DNS name of the Bitbucket server to be configured.',
    prompt=True
)
# Sonarqube (container)
@click.option(
    '--sonarqube/--no-sonarqube',
    default=False
)
@click.option(
    '--existing_vpc/--no_existing_vpc',
    default=False
)
@click.option(
    "--vpcid",
    help='Specify the ID of an existing VPC to use for ECS configuration',
    cls=Required,
    required_if='existing_vpc'
)
@click.option(
    "--vpc_cidr",
    help='Specify the desired CIDR block to use for VPC ECS configuration (default - 10.0.0.0/16)',
    default='10.0.0.0/16',
    cls=Required,
    required_if_not='existing_vpc',
    prompt=True
)
def scenario2(bitbucket_endpoint, bitbucket_userpass, bitbucket_publicip, existing_vpc, vpcid, vpc_cidr, sonarqube):
    """Installs stack with containerized Jenkins and preexisting Bitbucket"""

    click.secho('\n\nConfiguring Jenkins container', fg='blue')
    configure_jenkins_container(vpcid, vpc_cidr)

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
        click.secho('\n\nConfiguring Sonarqube container', fg='blue')
        configure_sonarqube_container()

    click.secho('\n\nStarting Terraform', fg='green')
    click.secho('\n\nTerraform output will be echoed here and captured to stack_creation.out', fg='green')

    exec_terraform_apply()
