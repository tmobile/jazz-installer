import click
from installer.cli.click_required import Required
from installer.configurators.jenkins_container import configure_jenkins_container
from installer.configurators.gitlab_container import configure_gitlab_container
from installer.configurators.sonarqube_container import configure_sonarqube_container
from installer.helpers.terraform import exec_terraform_apply


@click.command()
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
def scenario3(sonarqube, existing_vpc, vpcid, vpc_cidr):
    """Installs stack with containerized Jenkins and containerized Gitlab"""

    click.secho('\n\nConfiguring Jenkins server', fg='blue')
    configure_jenkins_container()
    click.secho('\nJenkins server configured!', fg='green')

    click.secho('\n\nConfiguring Gitlab server', fg='blue')
    configure_gitlab_container()

    if sonarqube:
        click.secho('\n\nConfiguring Sonarqube server', fg='blue')
        configure_sonarqube_container()

    click.secho('\n\nStarting Terraform', fg='green')
    click.secho('\n\nTerraform output will be echoed here and captured to stack_creation.out', fg='green')

    exec_terraform_apply()
