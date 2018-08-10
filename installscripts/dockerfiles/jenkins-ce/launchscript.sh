#Spin wheel for visual effects
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
sudo usermod -aG docker $(whoami) &> /dev/null &
spin_wheel $! "Adding the present user to docker group"

# Check if docker with same name exists. If yes, stop and remove the docker container.
sudo docker ps -a | grep -i jenkins-server &> /dev/null
if [ $? == 0 ] ; then
  echo "Detected a container with name: jenkins-server. Deleting it..."
  sudo docker stop jenkins-server &> /dev/null &
  spin_wheel $! "Stopping existing Jenkins Docker"
  sudo docker rm jenkins-server &> /dev/null &
  spin_wheel $! "Removing existing Jenkins Docker"
fi

# Check if docker volume exists. If yes, remove the docker volume.
sudo docker volume inspect jenkins-volume &> /dev/null
if [ $? == 0 ] ; then
  echo "Detected a volume with name: jenkins-volume. Deleting it..."
  sudo docker volume rm jenkins-volume &> /dev/null &
fi

# Building the custom docker image from the jenkins-ce base image
cd ../../../installscripts
passwd=`date | md5sum | cut -d ' ' -f1`
sudo docker build --build-arg adminpass=$passwd -t jenkins-ce-image -f dockerfiles/jenkins-ce/Dockerfile .

# Create the volume that we host the jenkins_home dir on dockerhost.
sudo docker volume create jenkins-volume &> /dev/null &
spin_wheel $! "Creating the Jenkins volume"

# Running the custom image
sudo docker run -d --name jenkins-server -p 8081:8080 -v jenkins-volume:/var/jenkins_home jenkins-ce-image

# Wainting for the container to spin up
sleep 60
echo "initialPassword is: $passwd"
sudo docker exec -u root -i jenkins-server bash -c "echo 'admin:$passwd' > /tmp/jazz-chef/authfile"

# Grab the variables
ip=`curl -sL http://169.254.169.254/latest/meta-data/public-ipv4`
mac=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs`
security_groups=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac%/}/security-group-ids`
subnet_id=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac%/}/subnet-id`

# Values to be passed to parameter list
jenkins_server_elb="$ip:8081"
jenkins_username="admin"
jenkins_passwd="$passwd"
jenkins_server_public_ip="$ip"
jenkins_server_ssh_login="root"
jenkins_server_ssh_port="2200"
jenkins_server_security_group="$security_groups"
jenkins_server_subnet="$subnet_id"

# Print the values to a temp file to be read from calling python script
echo "$jenkins_server_elb" > dockerfiles/jenkins-ce/docker_jenkins_vars
echo "$jenkins_username" >> dockerfiles/jenkins-ce/docker_jenkins_vars
echo "$jenkins_passwd" >> dockerfiles/jenkins-ce/docker_jenkins_vars
echo "$jenkins_server_public_ip" >> dockerfiles/jenkins-ce/docker_jenkins_vars
echo "$jenkins_server_ssh_login" >> dockerfiles/jenkins-ce/docker_jenkins_vars
echo "$jenkins_server_ssh_port" >> dockerfiles/jenkins-ce/docker_jenkins_vars
echo "$jenkins_server_security_group" >> dockerfiles/jenkins-ce/docker_jenkins_vars
echo "$jenkins_server_subnet" >> dockerfiles/jenkins-ce/docker_jenkins_vars
