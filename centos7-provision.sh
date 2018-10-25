#!/bin/sh
#
# File: centos7-provision.sh
# Description: Installs jazz prerequisites on a Centos7 ec2-instance.
#              if you already have the prerequisites installed, just run Installer.sh
#              directly from the from the cloned jazz-installer folder.
# Variables section

# URLS
JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip"
ATLASSIAN_CLI_URL="https://bobswift.atlassian.net/wiki/download/attachments/16285777/atlassian-cli-6.7.1-distribution.zip"
INSTALLER_GITHUB_URL="https://github.com/tmobile/jazz-installer.git"
PIP_URL="https://bootstrap.pypa.io/get-pip.py"

# Installation directory
INSTALL_DIR=`pwd`

# Log file to record the installation logs
LOG_FILE_NAME=provision_setup.out
LOG_FILE=`realpath $INSTALL_DIR/$LOG_FILE_NAME`
JAZZ_INSTALLER_BRANCH="master"

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
function spin_wheel () {
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
    # Download and Installing Softwares required for Jazz centos7-provision
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

    #Install Docker
    if command -v docker > /dev/null; then
        print_info "Docker already installed, using it"
    else
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2 >>$LOG_FILE &
        spin_wheel $! "Installing prerequisites for docker-ce"
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >>$LOG_FILE &
        spin_wheel $! "Adding yum repo for docker-ce"
        sudo yum install docker-ce -y >>$LOG_FILE &
        spin_wheel $! "Installing docker-ce"

    fi
    sudo systemctl start docker >>$LOG_FILE &
    spin_wheel $! "Starting docker-ce"
    sudo systemctl status docker >>$LOG_FILE &
    spin_wheel $! "Checking docker-ce service"
    sudo systemctl enable docker >>$LOG_FILE &
    spin_wheel $! "Enabling docker-ce service"
    sudo gpasswd -a $(whoami) docker >>$LOG_FILE &
    spin_wheel $! "Adding the present user to docker group"

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
    unzip -o $INSTALL_DIR/jazz_tmp/atlassian-cli-6.7.1-distribution.zip -d $INSTALL_DIR/jazz_tmp/ >>$LOG_FILE &
    spin_wheel $! "Fetching atlassian-cli"

    #Get Jazz installer code base
    if [ -z "$JAZZ_INSTALLER_BRANCH" ]; then
        echo "Jazz branch to clone"
        print_info "Skipping installer repo clone based on CLI flag"
    else
        sudo rm -rf jazz-installer
        git clone -b $JAZZ_INSTALLER_BRANCH $INSTALLER_GITHUB_URL --depth 1 >>$LOG_FILE &
        spin_wheel $! "Fetching jazz-installer repo"
    fi

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

# Running the selector
while [ $# -gt 0 ] ; do
    case "$1" in
        -h|--help)
            echo "Installs jazz prerequisites on a Centos7 ec2-instance."
            echo ""
            echo "./centos7-provision.sh [options]"
            echo ""
            echo "options:"
            echo "-ib, --installer-branch                     [optional] centos7-provision repo branch to use. Defaults to `master`"
            echo "-nc, --no-clone                             [optional] Skip cloning the jazz-installer repo into the current directory. Default: repo is cloned."
            echo "-v, --verbose 1|0                           [optional] Enable/Disable verbose centos7-provision logs. Default:0(Disabled)"
            echo "-t, --tags Key=stackName,Value=production   [optional] Specify as space separated key/value pairs"
            echo "-h, --help                                  [optional] Describe help"
            exit 0 ;;

        -ib|--installer-branch)
            shift
            if [ ! -z "$1" ] ; then
                JAZZ_INSTALLER_BRANCH="$1"
            else
                echo "No arguments supplied for installer branch name."
                echo "Usage: ./centos7-provision.sh -ib installer_branch_name"
                exit 1
            fi
            shift ;;

        -nc|--no-clone)
            shift
            JAZZ_INSTALLER_BRANCH=''
            shift ;;

        -v|--verbose)
            shift
            if [[ ("$#" -gt 0) && ("$1" == "1") ]] || [[ ("$#" -gt 0) && ("$1" == "0") ]] ; then
                VERBOSE="$1"
            else
                echo "Please specify 1 or 0 for verbosity. Enable/Disable verbose centos7-provision logs. Default:0(Disabled)"
                echo "Usage: ./centos7-provision --verbose 1"
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
                    echo "Usage: ./centos7-provision --tags Key=stackName,Value=production Key=department,Value=devops"
                    exit 1
                fi
                shift
            done ;;

        *)
            echo "Invalid flag!"
            echo "Please run './centos7-provision.sh -h' to see all the available options."
            exit 1 ;;
    esac
done

install_packages $VERBOSE
