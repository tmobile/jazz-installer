#!/bin/bash
token=$1
ns_id_slf=$2
gitlab_admin=$3
gitlab_passwd=$4
gitlab_public_ip=$5

# Function to push code to Gitlab SLF projects
pop_gitlab_repo()
{
    # Parameter sequence
    # 1, 2, 3, 4, 5 : reponame, token, namespace_id, username, password

    # Creating the repo
    curl -sL --header "PRIVATE-TOKEN: $2" -X POST "http://$gitlab_public_ip/api/v4/projects?name=$1&namespace_id=$3"

    # Cloning the repo, adding contents to the repo and commit-push to remote.
    cd push-to-slf
    git clone http://$4:$5@$gitlab_public_ip/slf/$1.git
    cd $1
    cp -r ../../jazz-core/$1/* .
    git add -A
    git commit -m 'First commit'
    git push -u origin master
    cd ../..
}

# Place holder for populating values in jazz-installer-vars.json
# Logic to modify json file

# Traversing through the jazz-core directory to grab directory names and adding them to an array 'repos'
cd ./jazz-core
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

