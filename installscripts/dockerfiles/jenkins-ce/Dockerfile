# Base Image and maintainer info
FROM jenkins/jenkins:lts
MAINTAINER JazzOSS Team

# Switching to root to configure the image with system packages
USER root
ARG adminpass
ENV JENKINS_USER admin
ENV JENKINS_PASS $adminpass
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
COPY dockerfiles/jenkins-ce/default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

RUN apt-get update && apt-get install -y vim curl sudo libtool autoconf make unzip rsync gcc autogen shtool pkg-config lsb-release python python-dev python-pip python-setuptools groff less && \
curl https://bootstrap.pypa.io/get-pip.py | python && pip install --upgrade awscli && apt-get clean && pip install virtualenv && /usr/bin/easy_install virtualenv && \
wget -O /opt/apache-maven-3.5.2-bin.tar.gz https://archive.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz && \
tar xzvf /opt/apache-maven-3.5.2-bin.tar.gz -C  /opt && export PATH=$PATH:/opt/apache-maven-3.5.2/bin >> /etc/profile.d/maven.sh && ln -sf /opt/apache-maven-3.5.2/bin/mvn /usr/bin/mvn && \
curl -sL https://deb.nodesource.com/setup_8.x | bash && apt-get install -y nodejs && npm install  -global serverless@1.26.1 @angular/cli@1.7.3 jshint && \
wget -O /opt/sonar-scanner-cli-3.0.3.778-linux.zip https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip && \
unzip /opt/sonar-scanner-cli-3.0.3.778-linux.zip -d /opt && chown -R jenkins:jenkins /opt/sonar-scanner-3.0.3.778-linux && \
ln -sf /opt/sonar-scanner-3.0.3.778-linux/bin/sonar-scanner /bin/sonar-scanner && mkdir /var/log/depcheck_jazz/ && \
mkdir /var/log/depcheck_jazz/nistfiles && chown -R jenkins:jenkins /var/log/depcheck_jazz/ && \
wget -O /opt/dependency-check-3.2.1-release.zip https://bintray.com/jeremy-long/owasp/download_file?file_path=dependency-check-3.2.1-release.zip && \
unzip /opt/dependency-check-3.2.1-release.zip -d /opt && chown -R jenkins:jenkins /opt/dependency-check && \
ln -sf /opt//dependency-check/bin/dependency-check.sh /bin/dependency-check.sh && \
wget -O /opt/checkstyle-7.6-all.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-7.6.1/checkstyle-7.6.1-all.jar

# Copying plugins list. Downlading and installing plugins from Jenkins PluginsManager
COPY dockerfiles/jenkins-ce/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Copy the chef recipes, chefconfigs and bootstrap script
COPY --chown=jenkins:jenkins cookbooks  /tmp/jazz-chef/cookbooks

RUN chown -R jenkins:jenkins /tmp/jazz-chef
# Creating node_path directory
#RUN mkdir /var/jenkins_home/node

ADD cookbooks/jenkins/files/default/xmls.tar /var/jenkins_home/
COPY --chown=jenkins:jenkins cookbooks/jenkins/files/default/encrypt.groovy /var/jenkins_home/
COPY --chown=jenkins:jenkins cookbooks/jenkins/files/default/credentials.xml /var/jenkins_home/
COPY --chown=jenkins:jenkins cookbooks/jenkins/files/default/config.xml /var/jenkins_home/
COPY --chown=jenkins:jenkins cookbooks/jenkins/files/default/scriptApproval.xml /var/jenkins_home/

# Switching back to Jenkins user for safety
USER jenkins

# Expose the jenkins port
EXPOSE 8081
