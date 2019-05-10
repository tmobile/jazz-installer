#!/bin/bash

# This script injects installer-based values into all the Jenkinsfiles* from the core repo.
repo_credential_id="jazz_repocreds"
aws_credential_id="jazz_awscreds"
repo_base=$1
repo_core="slf"
scm_type=$2
region=$3
instance_prefix=$4

inject_bootstrap_variables()
{
  cd ./jazz-core || exit
  file_name="Jenkinsfile*"

  # Record the files in an array: jenkinsfile_arr.
  jenkinsfile_arr=()
  for d in **/*/ ; do
      file=$(find "$d" -type f -name "$file_name")
      if [[ "$file" =~ Jenkinsfile* ]] ; then
        # shellcheck disable=SC2206
        jenkinsfile_arr=(${jenkinsfile_arr[@]} "$file")
     fi
  done

  # SED on the files found by traversing the array. It is assumed that all the jenkinsfiles in the core repository must has these 3 varibales defined.
  for i in "${jenkinsfile_arr[@]}"; do
    sed -i "s,^@Field def repo_credential_id,@Field def repo_credential_id = \"$repo_credential_id\"," "$i"
    sed -i "s,^@Field def aws_credential_id,@Field def aws_credential_id = \"$aws_credential_id\"," "$i"
    sed -i "s,^@Field def region,@Field def region = \"$region\"," "$i"
    sed -i "s,^@Field def instance_prefix,@Field def instance_prefix = \"$instance_prefix\"," "$i"
    sed -i "s,^@Field def repo_base,@Field def repo_base = \"$repo_base\"," "$i"
    sed -i "s,^@Field def repo_core,@Field def repo_core = \"$repo_core\"," "$i"
	  sed -i "s,^@Field def scm_type,@Field def scm_type = \"$scm_type\"," "$i"
  done

  cd ..
}

inject_bootstrap_variables "$repo_credential_id" "$aws_credential_id" "$region" "$instance_prefix" "$repo_base" "$repo_core"
