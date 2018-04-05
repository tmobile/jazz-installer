spin_wheel()
{
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'

    pid=$1 # Process Id of the previous running command
    message=$2
    spin='-\|/'
    printf "\r$message...."
    i=0

    while ps -p $pid > /dev/null
    do
        #echo $pid $i
        i=$(( (i+1) %4 ))
        printf "\r${GREEN}$message....${spin:$i:1}"
        sleep .05
    done

    wait "$pid"
    exitcode=$?
    if [ $exitcode -gt 0 ]
    then
        printf "\r${RED}$message....Failed${NC}\n"
        exit
    else
        printf "\r${GREEN}$message....Completed${NC}\n"

    fi
}
#Installing Docker-ce on centos7
sudo yum check-update &> /dev/null
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 &> /dev/null &
spin_wheel $! "Installing prerequisites for docker-ce"
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &> /dev/null &
spin_wheel $! "Adding yum repo for docker-ce"
sudo yum install docker-ce -y &> /dev/null &
spin_wheel $! "Installing docker-ce"

sudo systemctl start docker &> /dev/null &
spin_wheel $! "Starting docker-ce"
sudo systemctl status docker &> /dev/null &
spin_wheel $! "Checking docker-ce service"
sudo systemctl enable docker &> /dev/null &
spin_wheel $! "Enabling docker-ce service"
sudo gpasswd -a $(whoami) docker &> /dev/null &
spin_wheel $! "Adding the present user to docker group"
