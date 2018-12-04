import click
import click_spinner
from installer.cli.click_requiredif import RequiredIf
from installer.configurators.jenkins import configure_jenkins_docker
from installer.configurators.gitlab import configure_gitlab
from installer.configurators.sonarqube import configure_sonarqube_docker
from installer.helpers.terraform import exec_terraform_apply


@click.command()
# Sonarqube (container)
@click.option(
    '--sonarqube/--no-sonarqube',
    default=False
)
@click.option(
    '--existing-vpc/--no-existing-vpc',
    default=False
)
@click.option(
    "--vpcid",
    help='Specify the ID of an existing VPC to use for ECS configuration',
    cls=RequiredIf,
    required_if='existing_vpc',
    prompt=True
)
@click.option(
    "--vpc-cidr",
    help='Specify the desired CIDR block to use for VPC ECS configuration (default - 10.0.0.0/16)',
    default='10.0.0.0/16',
    cls=RequiredIf,
    required_if_not='existing_vpc',
    prompt=True
)
def scenario3(sonarqube):
    """Installs stack with containerized Jenkins and containerized Gitlab"""

    click.secho('\n\nConfiguring Jenkins server', fg='blue')
    with click_spinner.spinner():
        configure_jenkins_docker()
    click.secho('\nJenkins server configured!', fg='green')

    click.secho('\n\nConfiguring Gitlab server', fg='blue')
    # Get Bitbucket configuration details
    configure_gitlab()

    if sonarqube:
        click.secho('\n\nConfiguring Sonarqube server', fg='blue')
        with click_spinner.spinner():
            configure_sonarqube_docker()
        click.secho('\nSonarqube server configured!', fg='green')

    click.secho('\n\nStarting Terraform', fg='green')
    click.secho('\n\nTerraform output will be echoed here and captured to stack_creation.out', fg='green')

    exec_terraform_apply()
