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

# Check if docker with same name exists. If yes, stop and remove the docker container.
docker ps -a | grep -i jenkins-server &> /dev/null
if [ $? == 0 ] ; then
  echo "Detected a container with name: jenkins-server. Deleting it..."
  docker stop jenkins-server &> /dev/null &
  spin_wheel $! "Stopping existing Jenkins Docker"
  docker rm jenkins-server &> /dev/null &
  spin_wheel $! "Removing existing Jenkins Docker"
fi

# Check if docker volume exists. If yes, remove the docker volume.
docker volume inspect jenkins-volume &> /dev/null
if [ $? == 0 ] ; then
  echo "Detected a volume with name: jenkins-volume. Deleting it..."
  docker volume rm jenkins-volume &> /dev/null &
fi

# Create the volume
docker volume create jenkins-volume &> /dev/null &
spin_wheel $! "Creating the Jenkins Docker volume"

# Pull the docker image from ECR (this generates a docker login shell script, which we pipe to sh via stdin)
aws ecr get-login --registry-ids 108206174331 --no-include-email --region us-east-1 | /bin/sh &> /dev/null
docker pull 108206174331.dkr.ecr.us-east-1.amazonaws.com/jazz-oss:jenkins &> /dev/null &
spin_wheel $! "Pulling the Jenkins Docker image"

# Run the docker container from the using the above image and volumes.
docker run -dt -p 2200:2200 -p 8081:8080 --name=jenkins-server --mount source=jenkins-volume,destination=/var/lib/jenkins 108206174331.dkr.ecr.us-east-1.amazonaws.com/jazz-oss:jenkins &> /dev/null &
spin_wheel $! "Spinning up the Jenkins Docker container"

# Grab the pem key for further jenkins configurations
docker cp jenkins-server:/root/.ssh/id_rsa ./jenkinskey.pem
sudo chmod +r ./jenkinskey.pem
variablesfile=~/jazz-installer/installscripts/jazz-terraform-unix-noinstances/terraform.tfvars
sed -i'.bak' 's|\(jenkins_ssh_key \= \)\(.*\)|\1\"../sshkeys/dockerkeys/jenkinskey.pem\"|g' $variablesfile

sleep 20 &
spin_wheel $! "Initializing the Jenkins container"

#Installing Pip in Jenkins
docker exec jenkins-server apt-get update &> /dev/null &
spin_wheel $! "Updating Jenkins docker container"
docker exec jenkins-server apt-get install python-pip -y &> /dev/null &
spin_wheel $! "Installing python-pip in Jenkins container"
docker exec jenkins-server pip install --upgrade pip &> /dev/null &
spin_wheel $! "Upgrading pip in Jenkins container"
docker exec jenkins-server chmod -R o+w /usr/local/lib/python2.7/dist-packages &> /dev/null &
spin_wheel $! "Granting permissions to other users to pip install"

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
