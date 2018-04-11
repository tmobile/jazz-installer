#!/bin/bash
#
# File: Installer.sh
# Description: Installs the Jazz serverless framework from Centos7 ec2-instance.
#
# ---------------------------------------------
# Usage:
# ---------------------------------------------
# To Installer, run:
# ./Installer -b branch_name
# ---------------------------------------------

# Variables section

# URLS
JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"
AWSCLI_URL="https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.11.6/terraform_0.11.6_linux_amd64.zip"
ATLASSIAN_CLI_URL="https://bobswift.atlassian.net/wiki/download/attachments/16285777/atlassian-cli-6.7.1-distribution.zip"
INSTALLER_GITHUB_URL="https://github.com/tmobile/jazz-installer.git"
PIP_URL="https://bootstrap.pypa.io/get-pip.py"

# Installation directory
INSTALL_DIR=`pwd`
REPO_PATH=$INSTALL_DIR/jazz-installer

# Log file to record the installation logs
LOG_FILE_NAME=installer_setup.out
LOG_FILE=`realpath $INSTALL_DIR/$LOG_FILE_NAME`
JAZZ_BRANCH=""

# Default verbosity of the installation
VERBOSE=0

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'

print_info()
{
    printf "\r${GREEN}$1${NC}\n" 1>&3 2>&4
}

print_error()
{
    printf "\r${RED}$1${NC}\n" 1>&3 2>&4
}

#Spin wheel
spin_wheel()
{
        pid=$1 # Process Id of the previous running command
        message=$2
        spin='-\|/'
        printf "\r$message...." 1>&3 2>&4
        i=0

        while ps -p $pid > /dev/null
        do
          i=$(( (i+1) %4 ))
          printf "\r${GREEN}$message....${spin:$i:1}" 1>&3 2>&4
          sleep .05
        done

        wait "$pid"
        exitcode=$?
        if [ $exitcode -gt 0 ]
        then
                print_error "$message....Failed"
                exit
        else
                print_info "$message....Completed"

        fi
}
trap 'printf "${RED}\nCancelled....\n${NC}" 1>&3 2>&4; exit' 2
trap '' 20

function install_packages () {
  # Download and Installing Softwares required for Jazz Installer
  # 1. GIT
  # 2. Java Jdk - 8u112-linux-x64
  # 3. Unzip
  # 4. AWSCLI
  # 5. Terraform
  # 7. Atlassian CLI - 6.7.1

  #Fork output redirection so we can control output if VERBOSE is set
  exec 3>&1
  exec 4>&2

  # print verbosity mode during installation
  if [ "$1" == 1 ]; then
    print_info "You have started the installer in verbose mode" 1>&3 2>&4
  elif [ "$1" == 0 ]; then
    # Redirecting the stdout and stderr to /dev/null for non-verbose installation
    exec 1>/dev/null
    exec 2>/dev/null
    print_info "You have started the installer in non-verbose mode" 1>&3 2>&4
  fi
  print_info "You may view the detailed installation logs at $LOG_FILE" 1>&3 2>&4

  # Install git
  if command -v git > /dev/null; then
      print_info "Git already installed, using it"
  else
      sudo yum install -y git >>$LOG_FILE &
      spin_wheel $! "Installing git"
  fi

  # Download and Install java
  if command -v java > /dev/null; then
      print_info "Java already installed, using it"
  else
      curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_URL -o jdk-8u112-linux-x64.rpm >>$LOG_FILE &
      spin_wheel $! "Downloading java"

      sudo rpm -ivh --force ./jdk-8u112-linux-x64.rpm >>$LOG_FILE &
      spin_wheel $! "Installing java"

      rm -rf jdk-8u112-linux-x64.rpm
  fi

  # Download and Install unzip
  if command -v unzip > /dev/null; then
      print_info "Unzip already installed, using it"
  else
      sudo yum install -y unzip >>$LOG_FILE &
      spin_wheel $! "Installing unzip"
  fi

  # Create a temporary folder .
  # Here we will have all the temporary files needed and delete it at the end
  sudo rm -rf $INSTALL_DIR/jazz_tmp
  mkdir $INSTALL_DIR/jazz_tmp

  #Download and Install Terraform
  curl -v -L $TERRAFORM_URL -o $INSTALL_DIR/jazz_tmp/terraform.zip >>$LOG_FILE &
  spin_wheel $! "Downloading terraform"
  sudo unzip -o $INSTALL_DIR/jazz_tmp/terraform.zip -d /usr/bin>>$LOG_FILE &
  spin_wheel $! "Installing terraform"

  #Downloading and Install atlassian-cli
  curl -L $ATLASSIAN_CLI_URL -o $INSTALL_DIR/jazz_tmp/atlassian-cli-6.7.1-distribution.zip >>$LOG_FILE &
  spin_wheel $! "Downloading atlassian-cli"
  unzip -o $INSTALL_DIR/jazz_tmp/atlassian-cli-6.7.1-distribution.zip  >>$LOG_FILE &
  spin_wheel $! "Installing atlassian-cli"

  #Get Jazz Installer code base
  sudo rm -rf jazz-installer
  git clone -b $JAZZ_BRANCH $INSTALLER_GITHUB_URL >>$LOG_FILE &
  spin_wheel $! "Downloading jazz Installer"

  #Download and install pip
  if command -v pip > /dev/null; then
      print_info "pip already installed, using it"
  else
     curl -sL $PIP_URL -o get-pip.py
     sudo python get-pip.py >>$LOG_FILE &
     spin_wheel $! "Downloading and installing pip"
  fi

  if command -v aws > /dev/null; then
      print_info "awscli already installed, using it"
  else
      # Download and Install awscli
      sudo pip install awscli >> $LOG_FILE &
      spin_wheel $! "Downloading & installing awscli bundle"
  fi

  #Undo output redirection and close unused file descriptors.
  exec 1>&3 3>&-
  exec 2>&4 4>&-
}

function post_installation () {
  # Move the software install log jazz Installer
  mv $LOG_FILE $REPO_PATH

  # Set the permissions
  chmod -R +x $REPO_PATH/installscripts/*
  mkdir -p $REPO_PATH/installscripts/sshkeys/dockerkeys

  # Call the python script to continue installation process
  cd $REPO_PATH/installscripts/wizard
  #sed -i "s|\"jazz_install_dir\".*$|\"jazz_install_dir\": \"$INSTALL_DIR\"|g" config.py
  python ./run.py $JAZZ_BRANCH $INSTALL_DIR

  # Clean up the jazz_tmp folder
  sudo rm -rf $INSTALL_DIR/jazz_tmp

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
    echo "-b, --branch                                [mandatory] Branch to build Jazz framework from"
    echo "-v, --verbose 1|0                           [optional] Enable/Disable verbose Installer logs. Default:0(Disabled)"
    echo "-t, --tags Key=stackName,Value=production   [optional] Specify as space separated key/value pairs"
    echo "-h, --help                                  [optional] Describe help"
    exit 0 ;;

    -b|--branch)
    shift
    if [ ! -z "$1" ] ; then
      JAZZ_BRANCH="$1"
    else
      echo "No arguments supplied for branch name. We need atleast branch name to kickoff the Installer.sh"
      echo "Usage: ./Installer.sh -b branch_name"
      exit 1
    fi
    shift ;;

    -v|--verbose)
    shift
    if [[ ("$#" -gt 0) && ("$1" == "1") ]] || [[ ("$#" -gt 0) && ("$1" == "0") ]] ; then
      VERBOSE="$1"
    else
      echo "Please specify 1 or 0 for verbosity. Enable/Disable verbose Installer logs. Default:0(Disabled)"
      echo "Usage: ./Installer --verbose 1"
      echo "---------------------"
      echo "Missing: Mandatory flag branchname '-b|--branch' not provided."
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


# Check if mandatory flag branchname is provided and verbosity is either 0|1
if [[ ! -z $JAZZ_BRANCH ]] && [[ ($VERBOSE == 0) || ($VERBOSE == 1) ]]; then
  install_packages $VERBOSE && post_installation
elif [ -z $JAZZ_BRANCH ]; then
  echo "Missing: Mandatory flag branchname '-b|--branch' not provided." 1>&3 2>&4
  echo "Please run './Installer.sh -h' to see all the available options." 1>&3 2>&4
fi
