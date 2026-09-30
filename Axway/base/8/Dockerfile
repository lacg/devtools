ARG BASE_IMAGE=centos
ARG BASE_IMAGE_VERSION=8

# Get the azul/zulu-openjdk-centos, latest is ok as it is for developers.
FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}

# Maintainer
LABEL maintainer="lgarcia@axway.com"

# Axway runtime distribution filename.
ARG BUILD_DATE
ARG BUILD_VERSION
ARG USER=axway

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_devtools_base:8"
LABEL org.label-schema.description="Baseline for the Axway API developer tools using CentOS 8."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -it lacg/axway_devtools_base:8 bash"

# Set time zone
ARG TIME_ZONE
RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/${TZ:America/Phoenix} /etc/localtime

# Update OS and libraries needed by tools.
# Remove the Failed to set locale, defaulting to C.UTF-8 error message
# https://stackoverflow.com/questions/58497037/error-with-failed-to-set-locale-defaulting-to-c-on-centos-at-the-docker-envir
RUN dnf install -y -q --nodocs glibc-langpack-en epel-release && \
    # Update the environment.
    dnf update -y -q --nodocs && \
    # In CentOS 8, the GNU C Library (glibc) no longer includes libnsl and glibc-langpack-en libraries.
    # https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_installation/apigtw_install/system_requirements/index.html
    dnf install -y -q --nodocs \
    libnsl \
    # Install the open Java JDK 1.8 and sudo
    # yum install -y -q java-1.8.0-openjdk java-1.8.0-openjdk-devel sudo && \
    # Install the EPEL 8 for tini and sudo.
    epel-release \
    tini \
    sudo && \
    dnf clean all -y -q && \
    rm -rf /var/cache/dnf

# Updating the JAVA_HOME to use the OpenJDK to avoid using Oracle Java.
ENV JAVA_HOME /etc/alternatives/jre

# Create axway user and group and change to it.
# /opt/files - Directory used for the installation and licensing files.
# ll - just an alias to easy our lifes.
RUN useradd -m $USER && echo "$USER:$USER" | chpasswd && \
    gpasswd -a $USER $USER && \
    usermod -aG wheel $USER && \
    mkdir -p /opt/files && \
    chown -R $USER:$USER /opt && \
    echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers && \
    # Add aliases and environment variables to /etc/profile.d/aliases.sh
    # https://forums.centos.org/viewtopic.php?t=51710
    echo "alias ll='ls -larth'" >> /etc/profile.d/aliases.sh && \
    chmod +x /etc/profile.d/aliases.sh && \
    /etc/profile.d/aliases.sh && \
    touch /home/$USER/.Xauthority && \
    chown -R $USER:$USER /home/$USER

# Copy the shell scripts to the default user and set the default user and it's variables.
COPY --chown=$USER:$USER ./Scripts/* /home/$USER/
USER $USER
WORKDIR /home/$USER
ENV HOME /home/$USER

# Used by many APIM applications.
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/opt/axway/apigateway/Linux.x86_64/lib/"