#!/usr/bin/python
import sys
import os
import jazz_scenarios as scenarios


def main():
    """
        Entry point for Jazz Installer.
    """
    try:
        git_branch_name = sys.argv[1]
        # Set the passed-in repo root path as an env var here,
        # so subsequent scripts don't need to hardcode absolute paths.
        os.environ['JAZZ_INSTALLER_ROOT'] = sys.argv[2]
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
