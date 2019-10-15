import click
import os
from installer.helpers.destroyprep import destroyprep
from installer.helpers.terraform import exec_terraform_destroy, get_terraform_output_var


@click.command()
@click.option(
    '--mode',
    type=click.Choice(['all', 'frameworkonly']),
    help='`all` to remove Jazz and all deployed services, \
    `frameworkonly` to remove Jazz but leave deployed services alone',
    required=True
)
@click.option('--aws_access_key', prompt=True, envvar='AWS_ACCESS_KEY_ID')
@click.option('--aws_secret_key', prompt=True, envvar='AWS_SECRET_ACCESS_KEY')
def uninstall(mode, aws_access_key, aws_secret_key):
    """Uninstalls the Jazz Stack."""
    click.secho('\n\nConfiguring uninstall', fg='blue')
    click.secho('\nLogging to `uninstall.log`', fg='green')
    os.environ['AWS_ACCESS_KEY_ID'] = aws_access_key
    os.environ['AWS_SECRET_ACCESS_KEY'] = aws_secret_key
    click.secho('\n\n Collecting terraform output vars from existing install...', fg='blue')
    stackprefix = get_terraform_output_var("jazzprefix")
    identity = get_terraform_output_var("jazzusername")
    region = get_terraform_output_var("region")
    click.secho(
        '\nRunning destroy prep with option: {0}, prefix: {1}, and identity: {2}'
        .format(mode, stackprefix, identity), fg='green')

    if mode == "all":
        destroyprep(stackprefix, identity, region, True)
    else:
        destroyprep(stackprefix, identity, region, False)

    click.secho('\nRunning terraform destroy', fg='green')
    exec_terraform_destroy()
