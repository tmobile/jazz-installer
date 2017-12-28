FROM ubuntu
MAINTAINER Jazz-OSS feroz.shaikh@ust-global.com
RUN apt-get update
RUN apt-get install apt-utils curl sudo vim wget apt-transport-https default-jdk -y
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JENKINS_HOME /var/lib/jenkins
RUN wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
RUN echo deb https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list
RUN apt-get update
RUN apt-get install jenkins -y
RUN update-rc.d jenkins defaults
RUN apt-get install -y openssh-server supervisor
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/Port 22/Port 2200/' /etc/ssh/sshd_config
RUN ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
RUN cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
RUN mkdir /home/centos
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 2200 8080
CMD ["/usr/bin/supervisord"]
