import click
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
def uninstall(mode):
    """Uninstalls the Jazz Stack."""
    click.secho('\n\nConfiguring uninstall', fg='blue')
    click.secho('\nLogging to `uninstall.log`', fg='green')

    click.secho('\n\n Collecting terraform output vars from existing install...', fg='blue')
    stackprefix = get_terraform_output_var("jazzprefix")
    identity = get_terraform_output_var("jazzusername")

    click.secho(
        '\nRunning destroy prep with option: {0}, prefix: {1}, and identity: {2}'
        .format(mode, stackprefix, identity), fg='green')

    if mode == "all":
        destroyprep(stackprefix, identity, True)
    else:
        destroyprep(stackprefix, identity, False)

    click.secho('\nRunning terraform destroy', fg='green')
    exec_terraform_destroy()
