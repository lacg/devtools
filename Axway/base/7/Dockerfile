# Get the azul/zulu-openjdk-centos, latest is ok as it is for developers.
FROM centos:7
# https://hub.docker.com/r/consol/centos-xfce-vnc
#FROM consol/centos-xfce-vnc:nightly
# https://github.com/DrSnowbird/eclipse-docker-vnc
# FROM openkbs/jdk-mvn-py3-vnc

# Maintainer
LABEL maintainer="lgarcia@axway.com"

# Axway runtime distribution filename.
ARG BUILD_DATE
ARG BUILD_VERSION
ARG DEFAULT_USER=axway
# ARG DEFAULT_USER=developer

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_devtools_base:7"
LABEL org.label-schema.description="Baseline for the Axway API developer tools using CentOS 7 with XFCE and VNC."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
# Run command with mapping to local port 5901 (vnc protocol) and 6901 (vnc web access)
# Change the default user and group within a container to your own with adding axway:axway
LABEL org.label-schema.docker.cmd="docker container run -d --user $DEFAULT_USER:$DEFAULT_USER -p 5901:5901 -p 6901:6901 lacg/axway_devtools_base:7"

USER root

# Update OS and libraries needed by tools.
# CentOS
RUN yum update -y -q && \
    yum install -y -q -e 0 glibc-2.17-307.el7.1.i686 gtk2-2.24.31-1.el7.i686 libXtst-1.2.3-1.el7.i686 java-1.8.0-openjdk java-1.8.0-openjdk-devel sudo xorg-x11-xauth xorg-x11-fonts* xorg-x11-utils && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# Updating the JAVA_HOME to use the OpenJDK to avoid using Oracle Java.
ENV JAVA_HOME /etc/alternatives/jre

# Create $DEFAULT_USER user and group and change to it.
# /opt/files - Directory used for the installation and licensing files.
# ll - just an alias to easy our lifes.
RUN useradd -m $DEFAULT_USER && echo "$DEFAULT_USER:$DEFAULT_USER" | chpasswd && \
    gpasswd -a $DEFAULT_USER $DEFAULT_USER && \
#    usermod -aG wheel $DEFAULT_USER && \
#    usermod -aG sudo $DEFAULT_USER && \
    mkdir -p /opt/files && \
    mkdir -p /opt/axway && \
    chown -R $DEFAULT_USER:$DEFAULT_USER /opt && \
    echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers && \
    echo "%sudo  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers && \
    echo "alias ll='ls -larth'" >> /etc/bashrc && \
    echo "export LD_LIBRARY_PATH=/opt/axway/policystudio:/opt/axway/configurationstudio:/opt/axway/apigateway/Linux.x86_64/lib/" >> /etc/bashrc && \
    mkdir -p /home/$DEFAULT_USER/apiprojects && \
    touch /home/$DEFAULT_USER/.Xauthority && \
    chown -R $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER

COPY --chown=$DEFAULT_USER:$DEFAULT_USER ./Scripts/* /home/$DEFAULT_USER/
COPY --chown=$DEFAULT_USER:$DEFAULT_USER ./Scripts/axway.png /opt/axway/

USER $DEFAULT_USER

WORKDIR /home/$DEFAULT_USER

VOLUME ["/home/$DEFAULT_USER/apiprojects"]