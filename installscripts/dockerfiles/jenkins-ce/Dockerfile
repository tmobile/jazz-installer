# Base Image and maintainer info
FROM jenkins/jenkins:2.121.3
MAINTAINER JazzOSS Team

ARG goVersion=1.10.3
# Switching to root to configure the image with system packages
USER root
RUN apt-get update && apt-get install -y vim curl sudo libtool autoconf make unzip rsync gcc autogen shtool pkg-config lsb-release python python-dev python-pip python-setuptools groff less \
python3.5 python3-dev python3-pip build-essential libssl-dev libffi-dev && curl https://bootstrap.pypa.io/get-pip.py | python && curl https://bootstrap.pypa.io/get-pip.py | python3 && pip install --upgrade awscli && \
apt-get clean && pip install virtualenv && /usr/bin/easy_install virtualenv
RUN wget -O /opt/apache-maven-3.5.2-bin.tar.gz https://archive.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz && tar xzvf /opt/apache-maven-3.5.2-bin.tar.gz -C  /opt && export PATH=$PATH:/opt/apache-maven-3.5.2/bin >> /etc/profile.d/maven.sh && ln -sf /opt/apache-maven-3.5.2/bin/mvn /usr/bin/mvn
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash && apt-get install -y nodejs && npm install  -global serverless@1.30.0 @angular/cli@1.7.3 jshint
# Setting alias for python2 and python3
RUN alias python=/usr/bin/python
RUN alias python3=/usr/bin/python3
# Install scripts for golang
RUN curl -O https://storage.googleapis.com/golang/go${goVersion}.linux-amd64.tar.gz && tar -xvf go${goVersion}.linux-amd64.tar.gz && mv go /usr/local
ENV GOROOT /usr/local/go
ENV GOBIN  /usr/local/go/bin
ENV GOPATH /usr/local/go/src
ENV PATH $GOROOT:$GOBIN:$GOPATH:$PATH
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

# Copying plugins list. Downlading and installing plugins from Jenkins PluginsManager
COPY dockerfiles/jenkins-ce/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Copy the chef recipes, chefconfigs and bootstrap script
COPY --chown=jenkins:jenkins cookbooks  /tmp/jazz-chef/cookbooks
COPY --chown=jenkins:jenkins dockerfiles/jenkins-ce/chefInstaller.sh /tmp/jazz-chef/chefInstaller.sh

RUN chown -R jenkins:jenkins /tmp/jazz-chef
# Creating node_path directory
RUN mkdir /var/jenkins_home/node

# Setting execute bit and executing the bootstrap script
RUN chmod 777 /tmp/jazz-chef/chefInstaller.sh
RUN bash /tmp/jazz-chef/chefInstaller.sh

# Switching back to Jenkins user for safety
USER jenkins

# Expose the jenkins port
EXPOSE 8081
