FROM ubuntu
MAINTAINER Jazz-OSS feroz.shaikh@ust-global.com
RUN apt-get update
RUN apt-get install apt-utils wget apt-transport-https default-jdk -y
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JENKINS_HOME /var/lib/jenkins
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
RUN wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
RUN echo deb https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list
RUN apt-get update
RUN apt-get install jenkins -y
RUN update-rc.d jenkins defaults
ENTRYPOINT service jenkins start && bash
EXPOSE 8080
