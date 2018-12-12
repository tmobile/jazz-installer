 #!/usr/bin/bash
 
 # Quit on error.
 set -e
 # Treat undefined variables as errors.
 set -u
 
 
 function main {
     local jenkins_user_uid="${1:-}"
     local jenkins_user_gid="${2:-}"
	 local jenkins_user="${3:-}"
	 
     # Change the uid
     if [[ -n "${jenkins_user_uid:-}" ]]; then
         usermod -u "${jenkins_user_uid}" "${jenkins_user}"
     fi
     # Change the gid
     if [[ -n "${jenkins_user_gid:-}" ]]; then
         groupmod -g "${jenkins_user_gid}" "${jenkins_user}"
     fi
 
     # Setup permissions on the run directory where the sockets will be
     # created, so we are sure the app will have the rights to create them.
 
     # Make sure the folder exists.
     mkdir /var/run/"${jenkins_user}"
     # Set owner.
     chown "${jenkins_user}":"${jenkins_user}" /var/run/"${jenkins_user}"
     # Set permissions.
     chmod u=rwX,g=rwX,o=--- /var/run/"${jenkins_user}"
 }
 
 
 main "$@"