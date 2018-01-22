# This script injects installer-based values into all the Jenkinsfiles* from the core repo.
repo_credential_id="jenkins1cred"
repo_base=$1
repo_core="slf"

inject_bootstrap_variables()
{
  cd ./jazz-core
  file_name=Jenkinsfile*

  # Record the files in an array: jenkinsfile_arr.
  jenkinsfile_arr=()
  for d in */ ; do
    file=`find "$d" -type f -name "$file_name"`
    if [[ "$file" =~ Jenkinsfile* ]] ; then
      jenkinsfile_arr=(${jenkinsfile_arr[@]} "$file")
    fi
  done

  # SED on the files found by traversing the array. It is assumed that all the jenkinsfiles in the core repository must has these 3 varibales defined.
  for i in "${jenkinsfile_arr[@]}"; do
    sed -i "s,^@Field def repo_credential_id,@Field def repo_credential_id = \"$repo_credential_id\"," "$i"
    sed -i "s,^@Field def repo_base,@Field def repo_base = \"$repo_base\"," "$i"
    sed -i "s,^@Field def repo_core,@Field def repo_core = \"$repo_core\"," "$i"
  done

  cd ..
}

inject_bootstrap_variables $repo_credential_id $repo_base $repo_core
