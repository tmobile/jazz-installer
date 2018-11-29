import click
import click_spinner
from installer.configurators.jenkins import configure_jenkins_docker
from installer.configurators.gitlab import configure_gitlab_docker
from installer.configurators.sonarqube import configure_sonarqube_docker
from installer.helpers.terraform import exec_terraform_apply


@click.command()
# Sonarqube (container)
@click.option(
    '--sonarqube/--no-sonarqube',
    default=False
)
def scenario3(sonarqube):
    """Installs stack with containerized Jenkins and containerized Gitlab"""

    click.secho('\n\nConfiguring Jenkins server', fg='blue')
    with click_spinner.spinner():
        configure_jenkins_docker()
    click.secho('\nJenkins server configured!', fg='green')

    click.secho('\n\nConfiguring Gitlab server', fg='blue')
    # Get Bitbucket configuration details
    with click_spinner.spinner():
        configure_gitlab_docker()
    click.secho('\nGitlab server configured!', fg='green')

    if sonarqube:
        click.secho('\n\nConfiguring Sonarqube server', fg='blue')
        with click_spinner.spinner():
            configure_sonarqube_docker()
        click.secho('\nSonarqube server configured!', fg='green')

    click.secho('\n\nStarting Terraform', fg='green')
    click.secho('\n\nTerraform output will be echoed here and captured to stack_creation.out', fg='green')

    exec_terraform_apply()
