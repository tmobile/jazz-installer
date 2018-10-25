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
docker ps -a | grep -i gitlab &> /dev/null
if [ $? == 0 ] ; then
    echo "Detected a container with name: gitlab. Deleting it..."
    docker stop gitlab &> /dev/null &
    spin_wheel $! "Stopping existing Gitlab Docker"
    docker rm gitlab &> /dev/null &
    spin_wheel $! "Removing existing Gitlab Docker"
    sudo rm -rf /srv/gitlab/*
fi

# Grabbing IP of the instance
ip=`curl -sL http://169.254.169.254/latest/meta-data/public-ipv4`

# Replacing Gitlab IP in default.rb file of Jenkins cookbook
attrbsfile=$JAZZ_INSTALLER_ROOT/installscripts/cookbooks/jenkins/attributes/default.rb
sed -i "s|default\['scm'\].*.|default\['scm'\]='gitlab'|g" $attrbsfile
sed -i "s|default\['scmelb'\].*.|default\['scmelb'\]='$ip'|g" $attrbsfile
sed -i "s|default\['scmpath'\].*.|default\['scmpath'\]='$ip'|g" $attrbsfile

# Running the Gitlab Docker
docker run --detach \
    --hostname $ip \
    --publish 443:443 --publish 80:80 --publish 2201:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest &> /dev/null &
spin_wheel $! "Initializing the Gitlab Docker"

sleep 180 &
spin_wheel $! "Launching the Gitlab Docker"

# Setting up admin credentials
passwd=$1
rootemail=$2
docker cp gitlab.sh gitlab:/root/gitlab.sh
docker exec gitlab /bin/bash /root/gitlab.sh $passwd $rootemail > credentials.txt 2>&1&
spin_wheel $! "Setting up admin credentials"

# Installing epel
sudo yum install epel-release -y &> /dev/null &
spin_wheel $! "Installing epel"

# Installing beautifulsoup4
sudo yum install python-beautifulsoup4 -y &> /dev/null &
spin_wheel $! "Installing beautifulsoup4"

# Installing lxml
sudo pip install lxml &> /dev/null &
spin_wheel $! "Installing lxml"

# Generating private tokens
echo "Generating private tokens:"
python privatetoken.py mytoken $passwd
echo "Private tokens generated"

# Grabbing the admin credentials
gitlab_admin=${rootemail//[^a-zA-Z0-9_-]/-}
gitlab_passwd=`cat credentials.txt | grep password| awk '{print $2}'`
token=`grep -i private credentials.txt | awk '{print $3}'`

# Setting gitlab token attribute in Jenkins Chef cookbook
sed -i "s|default\['gitlabtoken'\].*.|default\['gitlabtoken'\]='$token'|g" $attrbsfile
curl -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $token" -X PUT http://localhost/api/v4/users/1 -d '{"username":"'''$gitlab_admin'''"}'
# Create Groups CAS and SLF
echo "\nCreating SLF group"
curl -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $token" -X POST http://localhost/api/v4/groups -d '{"name":"SLF","path":"slf", "description": "Jazz framework, templates and services"}'
echo "\nCreating CAS group"
curl -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $token" -X POST http://localhost/api/v4/groups -d '{"name":"CAS","path":"cas", "description": "User created services repository"}'

echo "Obtaining group namespace IDs"
# Grabbing the namespace ID of CAS Group
echo "Getting namespace ID for SLF group"
ns_id_slf=`curl -sL --header "PRIVATE-TOKEN: $token" -X GET "http://localhost/api/v4/groups/slf" | awk -F',' '{print $1}' | awk -F':' '{print $2}'`
echo "Getting namespace ID for CAS group"
ns_id_cas=`curl -sL --header "PRIVATE-TOKEN: $token" -X GET "http://localhost/api/v4/groups/cas" | awk -F',' '{print $1}' | awk -F':' '{print $2}'`

# Writing values to credentials.txt
echo "GITLAB URL: http://$ip" > credentials.txt
echo "USERNAME: $gitlab_admin"  >> credentials.txt
echo "PASSWORD: $gitlab_passwd" >> credentials.txt
echo "PRIVATE TOKEN: $token" >> credentials.txt
echo "NSID SLF: $ns_id_slf" >> credentials.txt
echo "NSID CAS: $ns_id_cas" >> credentials.txt

# Redirecting ip, username and passwd
echo "$ip" > docker_gitlab_vars
echo "$gitlab_admin" >> docker_gitlab_vars
echo "$gitlab_passwd" >> docker_gitlab_vars

#Populating Gitlab config in Jenkins json file
echo "Updating Jenkins config with Gitlab info"
jenkinsJsonfile=$JAZZ_INSTALLER_ROOT/installscripts/cookbooks/jenkins/files/default/jazz-installer-vars.json
sed -i "s/TYPE\".*.$/TYPE\": \"gitlab\",/g" $jenkinsJsonfile
sed -i "s/PRIVATE_TOKEN\".*.$/PRIVATE_TOKEN\": \"$token\",/g" $jenkinsJsonfile
sed -i "s/CAS_NAMESPACE_ID\".*.$/CAS_NAMESPACE_ID\": \"$ns_id_cas\"/g" $jenkinsJsonfile
sed -i "s/BASE_URL\".*.$/BASE_URL\": \"$ip\",/g" $jenkinsJsonfile

# SCM selection for Gitlab trigger job in Jenkins
echo "Updating Jenkins job config"
variablesfile=$JAZZ_INSTALLER_ROOT/installscripts/jazz-terraform-unix-noinstances/terraform.tfvars
sed -i'.bak' 's|\(scmbb \= \)\(.*\)|\1false|g' $variablesfile
sed -i'.bak' 's|\(scmgitlab \= \)\(.*\)|\1true|g' $variablesfile
sed -i'.bak' 's|\(scm_slfid \= \)\(.*\)|\1\"'$ns_id_slf'\"|g' $variablesfile
sed -i'.bak' 's|\(scm_privatetoken \= \)\(.*\)|\1\"'$token'\"|g' $variablesfile
