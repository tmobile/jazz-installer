#!/usr/bin/python
import sys
import os
import jazz_scenarios as scenarios
import validate_tags
import subprocess
import ast
import json
from scenarios.support.jazz_common import replace_tfvars_map, replace_tfvars, get_tfvars_file


def main():
    """
        Entry point for Jazz Installer.
    """
    try:
        git_branch_name = sys.argv[1]
        # Set the passed-in repo root path as an env var here,
        # so subsequent scripts don't need to hardcode absolute paths.
        os.environ['CODE_QUALITY'] = 'false'
        if len(sys.argv) > 3:
            os.environ['CODE_QUALITY'] = sys.argv[3]

        os.environ['JAZZ_INSTALLER_ROOT'] = sys.argv[2]

        if len(sys.argv) > 4:
            input_tags = validate_tags.prepare_tags(sys.argv[4])
            try:
                aws_tags, aws_formatted_tags = validate_tags.validate_replication_tags(input_tags)
                replace_tfvars("aws_tags", str(aws_tags), get_tfvars_file())
                replace_tfvars_map("additional_tags", aws_formatted_tags, get_tfvars_file())
            except ValueError as err:
                print("Invalid Tag!" + str(err))
                sys.exit()

        key = 0
        while 1:
            print("\n\nSelect your install option...\n")
            scenarios.print_stack_options()
            selection = raw_input("Please enter your choice :")

            try:
                key = int(selection)
            except:
                print("Invalid input! Please enter an integer\n")
                continue

            if scenarios.is_valid_scenario(key):
                scenarios.execute(key, git_branch_name)
                break
            else:
                print("Invalid selection! Try again\n")

    except KeyboardInterrupt:
        print("\nKeyboard Interrupt detected exiting..")


# Entry Point
main()
