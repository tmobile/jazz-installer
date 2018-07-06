# Base Image and maintainer info
FROM jenkins/jenkins:lts
MAINTAINER JazzOSS Team

# Switching to root to configure the image with system packages
USER root
RUN apt-get update && apt-get install -y vim curl sudo libtool autoconf make unzip rsync gcc autogen shtool pkg-config
RUN apt-get update && apt-get install -y lsb-release
RUN apt-get update && \
    apt-get install -y \
        python \
        python-dev \
        python-pip \
        python-setuptools \
        groff \
        less \
    && pip install --upgrade awscli \
    && apt-get clean
RUN wget -O /tmp/apache-maven-3.5.2-bin.tar.gz https://archive.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz && tar xzvf /tmp/apache-maven-3.5.2-bin.tar.gz && export PATH=$PATH:/opt/apache-maven-3.5.2/bin >> /etc/profile.d/maven.sh && ln -sf /opt/apache-maven-3.5.2/bin/mvn /usr/bin/mvn
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash && apt-get install -y nodejs
RUN npm install  -global serverless@1.26.1 && npm install  -global @angular/cli@1.7.3 && npm install  -global jshint
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
