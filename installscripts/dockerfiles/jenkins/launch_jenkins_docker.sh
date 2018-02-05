#Installing Docker-ce on centos7
sudo yum check-update
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)

# Check if docker with same name exists. If yes, stop and remove the docker container.
sudo docker ps -a | grep -i jenkins-server &> /dev/null
if [ $? == 0 ] ; then
  echo "Detected a container with name: jenkins-server. Deleting it..."
  sudo docker stop jenkins-server
  sudo docker rm jenkins-server
fi

# Check if docker volume exists. If yes, remove the docker volume.
sudo docker volume inspect jenkins-volume &> /dev/null
if [ $? == 0 ] ; then
  echo "Detected a volume with name: jenkins-volume. Deleting it..."
  sudo docker volume rm jenkins-volume
fi

# Create the volume
sudo docker volume create jenkins-volume &> /dev/null

# Pull the docker image from ECR
region=`grep region ~/jazz-installer/installscripts/jazz-terraform-unix-noinstances/variables.tf  | cut -d' ' -f 9 | tr -d '"'`
aws ecr get-login --registry-ids 108206174331 --no-include-email --region $region > ecr_login_script
sudo bash ecr_login_script &> /dev/null
rm -f ecr_login_script
sudo docker pull 108206174331.dkr.ecr.us-east-1.amazonaws.com/jazz-oss:jenkins

# Run the docker container from the using the above image and volumes.
sudo docker run -dt -p 2200:2200 -p 8080:8080 --name=jenkins-server --mount source=jenkins-volume,destination=/var/lib/jenkins 108206174331.dkr.ecr.us-east-1.amazonaws.com/jazz-oss:jenkins

# Grab the pem key for further jenkins configurations
sudo docker cp jenkins-server:/root/.ssh/id_rsa ~/jenkinskey.pem
sudo chmod +r ~/jenkinskey.pem

# Print waiting message
echo "==============>"
echo "You will see the jenkins server login details after the stack creation!"
echo "Waiting for Jenkins Server to be ready..."
sleep 20

#Installing Pip in Jenkins
sudo docker exec -it jenkins-server /usr/bin/apt-get update
sudo docker exec -it jenkins-server /usr/bin/apt-get install python-pip -y 
sudo docker exec -it jenkins-server /usr/bin/pip install --upgrade pip
sudo docker exec -it jenkins-server /usr/bin/pip install virtualenv

# Grab the variables
ip=`curl -sL http://169.254.169.254/latest/meta-data/public-ipv4`
initialPassword=`sudo cat /var/lib/docker/volumes/jenkins-volume/_data/secrets/initialAdminPassword`
mac=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs`
security_groups=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac%/}/security-group-ids`
subnet_id=`curl -sL http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac%/}/subnet-id`

# Values to be passed to parameter list
jenkins_server_elb="$ip:8080"
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
