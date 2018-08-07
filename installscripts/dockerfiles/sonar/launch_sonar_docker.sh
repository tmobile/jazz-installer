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
docker ps -a | grep -i sonarqube &> /dev/null
if [ $? == 0 ] ; then
  echo "Detected a container with name: sonarqube. Deleting it..."
  docker stop sonarqube &> /dev/null &
  spin_wheel $! "Stopping existing SonarQube Docker"
  docker rm sonarqube &> /dev/null &
  spin_wheel $! "Removing existing SonarQube Docker"
fi

# Grabbing IP of the instance
ip=`curl -sL http://169.254.169.254/latest/meta-data/public-ipv4`

# Run the docker container from the using the above image and volumes.
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 -v sonarqube-temp:/opt/sonarqube/temp sonarqube &> /dev/null &
spin_wheel $! "Spinning up the SonarQube Docker container"

sleep 20 &
spin_wheel $! "Initializing the SonarQube container"

passwd=`date | md5sum | cut -d ' ' -f1`

sleep 30 &
spin_wheel $! "Setup admin credentials and qualityprofiles"
curl -u admin:admin -X POST -F 'name=JazzProfile' -F 'language=java' http://$ip:9000/api/qualityprofiles/create
curl -u admin:admin -X POST -F 'name=JazzProfile' -F 'language=js' http://$ip:9000/api/qualityprofiles/create
curl -u admin:admin -X POST -F 'name=JazzProfile' -F 'language=py' http://$ip:9000/api/qualityprofiles/create
curl -u admin:admin -X POST -F 'login=admin' -F 'password='''$passwd'''' -F 'previousPassword=admin' http://$ip:9000/api/users/change_password

sleep 10 &
spin_wheel $! "Add dependency owasp plugin"
docker exec -i sonarqube bash -c "wget -O extensions/plugins/sonar-dependency-check-plugin-1.1.0.jar https://bintray.com/stevespringett/owasp/download_file?file_path=org%2Fsonarsource%2Fowasp%2Fsonar-dependency-check-plugin%2F1.1.0%2Fsonar-dependency-check-plugin-1.1.0.jar && chown sonarqube:sonarqube extensions/plugins/sonar-dependency-check-plugin-1.1.0.jar"

sleep 10&
spin_wheel $! "Reinitialize SonarQube"
curl -u admin:$passwd -X POST http://$ip:9000/api/system/restart

# Values to be passed to parameter list
sonar_server_elb="$ip:9000"
sonar_username="admin"
sonar_passwd="$passwd"
sonar_server_public_ip="$ip"

# Writing values to credentials.txt
echo "Sonar URL: http://$sonar_server_elb" > credentials.txt
echo "USERNAME: $sonar_username"  >> credentials.txt
echo "PASSWORD: $sonar_passwd" >> credentials.txt

# Print the values to a temp file to be read from calling python script
echo "$sonar_server_elb" > docker_sonar_vars
echo "$sonar_username" >> docker_sonar_vars
echo "$sonar_passwd" >> docker_sonar_vars
echo "$sonar_server_public_ip" >> docker_sonar_vars
