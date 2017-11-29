#!/usr/bin/python
import sys
import jazz_scenarios as scenarios

def main():
    """
        Entry point for Jazz Installer.
    """
    git_branch_name = sys.argv[1]
    key = 0
    while 1:
        
        #Commeting this option as we only have currently one option to be selected
        #Later when we add new options we will uncomment this.
        #this code is been tested.
        """print("\n\nKindly select an option...\n")
        scenarios.print_stack_options()
        selection = raw_input("Please enter your choice :")"""

        try:
            #key = int(selection)
            key = 1 #Hardcoding 1 as we only have one option currently
        except:
            print("Invalid Input! Please enter an integer\n")
            continue

        if scenarios.is_valid_scenario(key):
            scenarios.execute(key, git_branch_name)
            break
        else:
            print("Invalid selection! Try again\n")


#Entry Point
main()
