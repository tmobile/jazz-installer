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

# Create the volume
sudo docker volume create jenkins-volume &> /dev/null &
spin_wheel $! "Creating the Jenkins volume"

# Pull the docker image from ECR
region=`grep region ~/jazz-installer/installscripts/jazz-terraform-unix-noinstances/variables.tf  | cut -d' ' -f 9 | tr -d '"'`
aws ecr get-login --registry-ids 108206174331 --no-include-email --region $region > ecr_login_script
sudo bash ecr_login_script &> /dev/null
rm -f ecr_login_script
sudo docker pull 108206174331.dkr.ecr.us-east-1.amazonaws.com/jazz-oss:jenkins &> /dev/null &
spin_wheel $! "Pulling the Jenkins docker image"

# Run the docker container from the using the above image and volumes.
sudo docker run -dt -p 2200:2200 -p 8081:8080 --name=jenkins-server --mount source=jenkins-volume,destination=/var/lib/jenkins 108206174331.dkr.ecr.us-east-1.amazonaws.com/jazz-oss:jenkins &> /dev/null &
spin_wheel $! "Spinning the Jenkins Docker"

# Grab the pem key for further jenkins configurations
sudo docker cp jenkins-server:/root/.ssh/id_rsa ./jenkinskey.pem
sudo chmod +r ./jenkinskey.pem
sed -i 's|jenkins_ssh_key.*.$|jenkins_ssh_key = "../sshkeys/dockerkeys/jenkinskey.pem"|' ~/jazz-installer/installscripts/jazz-terraform-unix-noinstances/variables.tf

sleep 20 &
spin_wheel $! "Initializing the Jenkins Container"

#Installing Pip in Jenkins
sudo docker exec -it jenkins-server /usr/bin/apt-get update &> /dev/null
spin_wheel $! "Updating Jenkins docker container"
sudo docker exec -it jenkins-server /usr/bin/apt-get install python-pip -y &> /dev/null
spin_wheel $! "Installing python-pip in Jenkins container"
sudo docker exec -it jenkins-server /usr/bin/pip install --upgrade pip &> /dev/null
spin_wheel $! "Upgrading pip in Jenkins container"
sudo docker exec -it jenkins-server /usr/bin/pip install virtualenv &> /dev/null
spin_wheel $! "Installing virtualenv in Jenkins container"

# Grab the variables
ip=`curl -sL http://169.254.169.254/latest/meta-data/public-ipv4`
initialPassword=`sudo cat /var/lib/docker/volumes/jenkins-volume/_data/secrets/initialAdminPassword`
mac=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs`
security_groups=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac%/}/security-group-ids`
subnet_id=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac%/}/subnet-id`

# Values to be passed to parameter list
jenkins_server_elb="$ip:8081"
jenkins_username="admin"
jenkins_passwd="$initialPassword"
jenkins_server_public_ip="$ip"
jenkins_server_ssh_login="root"
jenkins_server_ssh_port="2200"
jenkins_server_security_group="$security_groups"
jenkins_server_subnet="$subnet_id"

# Print the values to a temp file to be read from calling python script
echo "$jenkins_server_elb" > docker_jenkins_vars
echo "$jenkins_username" >> docker_jenkins_vars
echo "$jenkins_passwd" >> docker_jenkins_vars
echo "$jenkins_server_public_ip" >> docker_jenkins_vars
echo "$jenkins_server_ssh_login" >> docker_jenkins_vars
echo "$jenkins_server_ssh_port" >> docker_jenkins_vars
echo "$jenkins_server_security_group" >> docker_jenkins_vars
echo "$jenkins_server_subnet" >> docker_jenkins_vars
