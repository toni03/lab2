# dockerfile to build image for JBoss EAP 6.4

# start from rhel 7.2
FROM centos 

# file author / maintainer
MAINTAINER "FirstName LastName" "emailaddress@gmail.com"

# update OS
RUN yum -y update && \
yum -y install sudo openssh-clients telnet unzip java-1.8.0-openjdk-devel && \
yum clean all
WORKDIR /opt
RUN mkdir software
COPY jboss-eap-6.4.0.zip /opt/software
WORKDIR /opt/software
RUN unzip jboss-eap-6.4.0.zip -d /opt

### Set Environment
ENV JBOSS_HOME /opt/jboss-eap-6.4
COPY hello.war /opt/jboss-eap-6.4/standalone/deployments

### Create EAP User
RUN $JBOSS_HOME/bin/add-user.sh admin Pelicano,013 --silent

# Install mysql module
ADD module.xml /opt/jboss-eap-6.4/modules/com/mysql/main/module.xml
ADD mysql-connector-java-5.1.27-bin.jar /opt/jboss-eap-6.4/modules/com/mysql/main/mysql-connector-java-5.1.27-bin.jar
ADD standalone.xml /opt/jboss-eap-6.4/standalone/configuration/standalone.xml

# Install Java JDK
COPY jdk-7u80-linux-x64.rpm /opt/software
RUN  rpm -ivh /opt/software/jdk-7u80-linux-x64.rpm
ENV JAVA_HOME /usr/java/jdk1.7.0_80/
ENV PATH /usr/java/jdk1.7.0_80/bin:$PATH

### Configure EAP
RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> $JBOSS_HOME/bin/standalone.conf
#RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.socket.binding.port-offset=100\"" >> $JBOSS_HOME/bin/standalone.conf
### Open Ports
EXPOSE 8080 9990 9999 8009

WORKDIR /opt/jboss-eap-6.4/bin
RUN chmod 755 standalone.sh
ENTRYPOINT $JBOSS_HOME/bin/standalone.sh
