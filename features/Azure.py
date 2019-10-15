#!/usr/bin/env python3

import click

from extensions.azure.install import install
from extensions.azure.uninstall import uninstall
# The top level command line group
@click.group()
@click.version_option()
def cli():
    """Azure extension for the Jazz Serverless Development Platform (https://github.com/tmobile/jazz)"""
    pass


if __name__ == '__main__':
    cli.add_command(install)
    cli.add_command(uninstall)
    cli()
