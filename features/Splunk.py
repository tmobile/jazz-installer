#!/usr/bin/env python3

import click

from extensions.splunk.setup import install
# The top level command line group
@click.group()
@click.version_option()
def cli():
    """Installs splunk extension for the Jazz Serverless Development Platform (https://github.com/tmobile/jazz)"""
    pass


if __name__ == '__main__':
    cli.add_command(install)
    cli()
