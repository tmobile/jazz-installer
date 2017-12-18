#Installing Docker-ce on centos7
sudo yum check-update
sudo yum remove docker docker-common docker-selinux docker-engine -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)

#Configuring and pulling the jenkins-docker from ECR
sudo docker volume rm jenkins-volume
sudo docker volume create jenkins-volume
aws ecr get-login --no-include-email --region us-east-1 > ecr_login_script
sudo bash ecr_login_script && rm -f ecr_login_script
sudo docker pull 108206174331.dkr.ecr.us-east-1.amazonaws.com/jazz-oss-repo:jenkins-docker
sudo docker stop jenkins-server
sudo docker rm jenkins-server
sudo docker run -dt -p 8080:8080 --name=jenkins-server --mount source=jenkins-volume,destination=/var/lib/jenkins 108206174331.dkr.ecr.us-east-1.amazonaws.com/jazz-oss-repo:jenkins-docker /bin/bash
echo "Waiting for Jenkins Server to be ready..."
sleep 12
ip=`curl -sL http://169.254.169.254/latest/meta-data/public-ipv4`
initialPassword=`sudo cat /var/lib/docker/volumes/jenkins-volume/_data/secrets/initialAdminPassword`
echo "============>"
echo "Jenkins Docker Details:"
echo "PublicIp: $ip"
echo "Username: admin"
echo "Password: $initialPassword"
echo "============>"
