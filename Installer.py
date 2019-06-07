#!/usr/bin/env python3

# Description: Starts the Jazz serverless installer wizard.

import click
from installer.cli.scenario1cli import scenario1
from installer.cli.scenario2cli import scenario2
from installer.cli.scenario3cli import scenario3
from installer.cli.installcli import install
from installer.cli.uninstallcli import uninstall

# The top level command line group
@click.group()
@click.version_option()
def cli():
    """Installer for the Jazz Serverless Development Platform (https://github.com/tmobile/jazz)"""
    pass


if __name__ == '__main__':

    # The `install` command - args and actions that are common to all scenarios
    cli.add_command(install)

    # Add `uninstall` command as a top level command alongside `install`
    cli.add_command(uninstall)

    # Add scenarios as child commands to `install`
    install.add_command(scenario1)
    install.add_command(scenario2)
    install.add_command(scenario3)

    cli()
