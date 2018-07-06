# Base Image and maintainer info
FROM jenkins/jenkins:lts
MAINTAINER JazzOSS Team

# Switching to root to configure the image with system packages
USER root
RUN apt-get update && apt-get install -y vim curl sudo
RUN apt-get update && apt-get install -y lsb-release

# Copying plugins list. Downlading and installing plugins from Jenkins PluginsManager
COPY dockerfiles/jenkins-ce/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Copy the chef recipes, chefconfigs and bootstrap script
COPY --chown=jenkins:jenkins cookbooks  /tmp/jazz-chef/cookbooks
COPY --chown=jenkins:jenkins dockerfiles/jenkins-ce/bootstrap.sh /tmp/jazz-chef/bootstrap.sh

RUN chown -R jenkins:jenkins /tmp/jazz-chef
# Creating node_path directory
RUN mkdir /var/jenkins_home/node

# Setting execute bit and executing the bootstrap script
RUN chmod 777 /tmp/jazz-chef/bootstrap.sh
RUN bash /tmp/jazz-chef/bootstrap.sh

# Switching back to Jenkins user for safety
USER jenkins

# Expose the jenkins port
EXPOSE 8081
