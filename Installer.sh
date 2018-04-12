#!/bin/sh
#
# File: Installer.sh
# Description: Starts the Jazz serverless installer wizard.
#
# ---------------------------------------------
# Usage:
# ---------------------------------------------
# To Installer, run:
# ./Installer.sh
# ---------------------------------------------

# Variables section

# Installation directory
INSTALL_DIR=`pwd`

# Log file to record the installation logs
LOG_FILE_NAME=installer_setup.out
LOG_FILE=`realpath $INSTALL_DIR/$LOG_FILE_NAME`
JAZZ_BRANCH="master"

# Default verbosity of the installation
VERBOSE=0

function start_wizard () {
    # Set the permissions
    chmod -R +x $INSTALL_DIR/installscripts/*
    mkdir -p $INSTALL_DIR/installscripts/sshkeys/dockerkeys

    # Call the python script to continue installation process
    cd $INSTALL_DIR/installscripts/wizard

    python ./run.py $JAZZ_BRANCH $INSTALL_DIR

    setterm -term linux -fore green
    setterm -term linux -fore default
}

# Running the selector
while [ $# -gt 0 ] ; do
    case "$1" in
        -h|--help)
            echo "Jazz-installer - Installer for Jazz serverless framework"
            echo ""
            echo "./Installer.sh [options]"
            echo ""
            echo "options:"
            echo "-b, --branch                                [optional] Branch to build Jazz framework from. Defaults to `master`"
            echo "-t, --tags Key=stackName,Value=production   [optional] Specify as space separated key/value pairs"
            echo "-h, --help                                  [optional] Describe help"
            exit 0 ;;

        -b|--branch)
            shift
            if [ ! -z "$1" ] ; then
                JAZZ_BRANCH="$1"
            else
                echo "No arguments supplied for branch name."
                echo "Usage: ./Installer.sh -b branch_name"
                exit 1
            fi
            shift ;;

        -t|--tags)
            shift
            while [ "$#" -gt 0 ] ; do
                if [[ "$1" =~ Key=.*,Value=.* ]] && [[ ! "$1" =~ ";" ]] ; then
                    arr+=("$1")
                elif [[ $1 == -* ]] ; then break
                else
                    echo "Please specify tags in format: Key=stackName,Value=production"
                    echo "Usage: ./Installer --tags Key=stackName,Value=production Key=department,Value=devops"
                    exit 1
                fi
                shift
            done ;;

        *)
            echo "Invalid flag!"
            echo "Please run './Installer.sh -h' to see all the available options."
            exit 1 ;;
    esac
done

start_wizard
