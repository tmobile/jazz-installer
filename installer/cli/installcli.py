import click
import os
from installer.configurators.common import update_main_terraform_vars


@click.group()
@click.option(
    "--branch",
    "-b",
    help='Branch to build Jazz framework from. Defaults to `master`',
    default='master'
)
# TODO Maybe drop this
@click.option(
    "--region",
    "-r",
    help='AWS region to install in. Only the listed choices have been verified',
    type=click.Choice(['us-east-1', 'us-west-2']),
    default='us-east-1'
)
@click.option(
    "--tags",
    "-t",
    help=('Specify AWS tags as key/value pairs, e.g: -t Key=stackenv,Value=production. '
          'You may specify this option multiple times to add multiple key-value pairs, '
          'e.g: -t Key=stackenv,Value=production -t Key=admin,Value=dinky@nope.com'),
    multiple=True
)
@click.option(
    "--stackprefix",
    "-p",
    help='Specify a string prefix name for your stack (limited to 13 chars)',
    # TODO
    # type=click.IntRange(0, 13),
    # type=stackprefix_type,
    prompt=True
)
@click.option(
    "--adminemail",
    "-e",
    help='Specify an admin email address (will be used for Jazz admin login)',
    prompt=True
)
@click.option('--aws_access_key', prompt=True, envvar='AWS_ACCESS_KEY_ID')
@click.option('--aws_secret_key', prompt=True, envvar='AWS_SECRET_ACCESS_KEY')
def install(branch, adminemail, stackprefix, region, tags, aws_access_key, aws_secret_key):
    """Installs the Jazz Stack."""
    os.environ['AWS_ACCESS_KEY_ID'] = aws_access_key
    os.environ['AWS_SECRET_ACCESS_KEY'] = aws_secret_key
    click.secho('\n\nConfiguring install', fg='blue')
    click.secho('\nLogging to `install.log`', fg='green')
    update_main_terraform_vars(branch, adminemail, stackprefix, region, tags)
