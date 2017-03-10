# s2i-java
FROM core/builder-base-centos7
MAINTAINER Jorge Morales <jmorales@redhat.com>

# Install build tools on top of base image
# Java jdk 8, Maven 3.3, Gradle 3.4.1
RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y 

ENV MAVEN_VERSION 3.3.9
RUN (curl -0 http://www.eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && chmod -R a+rwX $HOME/.m2

ENV GRADLE_VERSION 3.4.1 
RUN curl -sL -0 https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/local/ && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    mv /usr/local/gradle-${GRADLE_VERSION} /usr/local/gradle && \
    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle

ENV PATH=/opt/maven/bin/:/opt/gradle/bin/:$PATH

LABEL io.k8s.description="Platform for building Java (fatjar) applications with maven or gradle" \
      io.k8s.display-name="Java S2I builder 1.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,maven-3,gradle-2.6,java,microservices,fatjar"

COPY ./contrib/settings.xml $HOME/.m2/

COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
CMD ["usage"]
