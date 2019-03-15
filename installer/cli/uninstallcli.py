import click
from installer.helpers.destroyprep import destroyprep


@click.group()
@click.option(
    '--mode',
    type=click.Choice(['all', 'frameworkonly']),
    help='`all` to remove Jazz and all deployed functions, \
    `frameworkonly` to remove Jazz but leave deployed functions alone',
    required=True
)
def uninstall(mode):
    """Uninstalls the Jazz Stack."""
    click.secho('\n\nConfiguring uninstall', fg='blue')
    click.secho('\nLogging to `uninstall.log`', fg='green')

    if mode == "all":
        destroyprep(True)
    else:
        destroyprep(False)
    # update_main_terraform_vars(branch, adminemail, stackprefix, region, tags)
