#!/usr/bin/env python3

import click

from extensions.multiaccount.install import install
from extensions.multiaccount.uninstall import uninstall
# The top level command line group
@click.group()
@click.version_option()
def cli():
    """Installs the MultiAccount extension for the Jazz Serverless Development Platform \
     (https://github.com/tmobile/jazz)"""
    pass


if __name__ == '__main__':
    cli.add_command(install)
    cli.add_command(uninstall)
    cli()
