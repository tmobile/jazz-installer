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

# Function to push code to Gitlab SLF projects
pop_gitlab_repo()
{
# Parameter sequence
# 1, 2, 3, 4, 5 : reponame, token, namespace_id, username, password

# Creating the repo
curl -sL 	--header "PRIVATE-TOKEN: $2" -X POST "http://localhost/api/v4/projects?name=$1&namespace_id=$3"

# Cloning the repo, adding contents to the repo and commit-push to remote.
cd push-to-slf
git clone http://$4:$5@localhost/slf/$1.git
cd $1
cp -r ../../jazz/$1/* .
git add -A
git commit -m 'First commit'
git push -u origin master
cd ../..
}

# Check if docker with same name exists. If yes, stop and remove the docker container.
sudo docker ps -a | grep -i gitlab &> /dev/null
if [ $? == 0 ] ; then
  echo "Detected a container with name: gitlab. Deleting it..."
  sudo docker stop gitlab &> /dev/null &
  spin_wheel $! "Stopping existing Gitlab Docker"
  sudo docker rm gitlab &> /dev/null &
  spin_wheel $! "Removing existing Gitlab Docker"
fi

# Grabbing IP of the instance
ip=`curl -sL http://169.254.169.254/latest/meta-data/public-ipv4`

# Replacing Gitlab IP in default.rb file of Jenkins cookbook
attrbsfile="~/jazz-installer/installscripts/cookbooks/jenkins/attributes/default.rb"
sed -i "s|default\['scm'\].*.|default\['scm'\]='gitlab'|g" $attrbsfile
sed -i "s|default\['scmelb'\].*.|default\['scmelb'\]='$ip'|g" $attrbsfile
sed -i "s|default\['scmpath'\].*.|default\['scmpath'\]='$ip'|g" $attrbsfile


# Running the Gitlab Docker
sudo docker run --detach \
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
docker cp gitlab.sh gitlab:/root/gitlab.sh
docker exec gitlab /bin/bash /root/gitlab.sh > credentials.txt 2>&1&
spin_wheel $! "Setting up admin credentials"

# Installing epel
sudo yum install epel-release -y &> /dev/null &
spin_wheel $! "Installing epel"

# Installing beautifulsoup4
sudo yum install python-beautifulsoup4 -y &> /dev/null &
spin_wheel $! "Installing beautifulsoup4"

# Generating private tokens
echo "Generating private tokens:"
python privatetoken.py mytoken 2018-12-31

# Grabbing the admin credentials
gitlab_admin=`cat credentials.txt | grep login| awk '{print $2}'`
gitlab_passwd=`cat credentials.txt | grep password| awk '{print $2}'`
token=`grep -i private credentials.txt | awk '{print $3}'`

# Replacing private token in jenkins file
sed -i "s|replace|$token|g" ~/jazz-installer/installscripts/cookbooks/jenkins/files/credentials/gitlab-token.sh

# Create Groups CAS and SLF
curl -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $token" -X POST http://localhost/api/v4/groups -d '{"name":"SLF","path":"slf", "description": "Group containing templates and Frameworks"}'
curl -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $token" -X POST http://localhost/api/v4/groups -d '{"name":"CAS","path":"cas", "description": "User created services repository"}'

# Grabbing the namespace ID of CAS Group
ns_id_slf=`curl -sL --header "PRIVATE-TOKEN: $token" -X GET "http://localhost/api/v4/groups/slf" | awk -F',' '{print $1}' | awk -F':' '{print $2}'`
ns_id_cas=`curl -sL --header "PRIVATE-TOKEN: $token" -X GET "http://localhost/api/v4/groups/cas" | awk -F',' '{print $1}' | awk -F':' '{print $2}'`

# Writing values to credentials.txt
echo "GITLAB URL: http://$ip" > credentials.txt
echo "USERNAME: $gitlab_admin"  >> credentials.txt
echo "PASSWORD: $gitlab_passwd" >> credentials.txt
echo "PRIVATE TOKEN: $token" >> credentials.txt
echo "NSID SLF: $ns_id_slf" >> credentials.txt
echo "NSID CAS: $ns_id_cas" >> credentials.txt


echo "http://$ip" > docker_gitlab_vars
echo "$gitlab_admin" >> docker_gitlab_vars
echo "$gitlab_passwd" >> docker_gitlab_vars

# Populating jenkins properties file
jenkinsfile="~/jazz-installer/installscripts/cookbooks/jenkins/files/node/jenkins-conf.properties"
sed -i "s/jazz_scm.*.$/jazz_scm=gitlab/g" $jenkinsfile
sed -i "s/gitlab_username.*.$/gitlab_username=$gitlab_admin/g" $jenkinsfile
sed -i "s/gitlab_password.*.$/gitlab_password=$gitlab_passwd/g" $jenkinsfile
sed -i "s/gitlab_private_token.*.$/gitlab_private_token=$token/g" $jenkinsfile
sed -i "s/gitlab_cas_name_space_id.*.$/gitlab_cas_name_space_id=$ns_id_cas/g" $jenkinsfile
sed -i "s/REPO_BASE.*.$/REPO_BASE=$ip/g" $jenkinsfile


# SCM selection for Gitlab trigger job in Jenkins & token replacement in triggerfile
variablesfile="~/jazz-installer/installscripts/jazz-terraform-unix-noinstances/variables.tf"
triggerfile="~/jazz-installer/installscripts/jazz-terraform-unix-noinstances/scripts/gitlab-trigger-job.sh"
sed -i "s|variable \"scmbb\".*.$|variable \"scmbb\" \{ default = false \}|g" $variablesfile
sed -i "s|variable \"scmgitlab\".*.$|variable \"scmgitlab\" \{ default = true \}|g" $variablesfile
sed -i "s|<secretToken>replace</secretToken>|<secretToken>$token</secretToken>|g" $triggerfile

# Place holder for populating values in jazz-installer-vars.json
# Logic to modify json file

# Traversing through the jazz-core directory to grab directory names and adding them to an array 'repos'
git clone https://github.com/tmobile/jazz.git
cd jazz/
repos=()
for d in */ ; do
	dir="${d%/}"
	if [ "$dir" != "wiki" ]; then
		repos=(${repos[@]} "$dir")
	fi
done
cd ../

# Adding projects(repos) to SLF group.
mkdir push-to-slf
for i in "${repos[@]}"; do
	pop_gitlab_repo $i $token $ns_id_slf $gitlab_admin $gitlab_passwd
done

# Removing the cloned Repo no longer needed.
rm -rf jazz
