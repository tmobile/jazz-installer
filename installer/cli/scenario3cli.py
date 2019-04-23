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
    "--vpcid",
    help='Specify the ID of an existing VPC to use for ECS configuration',
    cls=Required,
    required_if_not='vpc_cidr'
)
@click.option(
    "--vpc_cidr",
    help='Specify the desired CIDR block to use for VPC ECS configuration (default - 10.0.0.0/16)',
    default='10.0.0.0/16',
    cls=Required,
    required_if_not='vpcid',
    prompt=True
)
@click.option(
    "--ecs_range",
    help='Specify a CIDR block to define what IPs can access ECS instances (default - 0.0.0.0/0)',
    default='0.0.0.0/0',
    prompt=True
)
def scenario3(sonarqube, vpcid, vpc_cidr, ecs_range):
    """Installs stack with containerized Jenkins and containerized Gitlab"""

    click.secho('\n\nConfiguring Jenkins container', fg='blue')
    configure_jenkins_container(vpcid, vpc_cidr, ecs_range)
    click.secho('\nJenkins server configured!', fg='green')

    click.secho('\n\nConfiguring Gitlab container', fg='blue')
    configure_gitlab_container()

    if sonarqube:
        click.secho('\n\nConfiguring Sonarqube container', fg='blue')
        configure_sonarqube_container()

    click.secho('\n\nStarting Terraform', fg='green')
    click.secho('\n\nTerraform output will be echoed here and captured to stack_creation.out', fg='green')

    exec_terraform_apply()
