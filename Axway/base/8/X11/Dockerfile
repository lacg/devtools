ARG BASE_IMAGE=lacg/axway_devtools_base
ARG BASE_IMAGE_VERSION=8

# Get the centos, latest is ok as it is a dev environment.
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
LABEL org.label-schema.name="lacg/axway_devtools_x11:8"
LABEL org.label-schema.description="Baseline for the Axway API developer tools using CentOS 8 with VNC."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -it lacg/axway_devtools_x11:8 bash"

USER root

# Include the GTK+ and X-Window libraries.
# First we enable the PowerTools.
# https://linuxhint.com/enable-powertools-repository-centos/
# RUN dnf -y -q install dnf-plugins-core && \
#    dnf -y -q install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
#    dnf config-manager --set-enabled powertools && \
    # Install, configure and start SSHD needed for X11 access.
#    yum install -y -q openssh-server && \
#    ssh-keygen -A && \
#    /usr/sbin/sshd && \
# RUN yum install -y -q gtk3 libxtst6 dbus-x11 xorg-x11-xinit xdg-utils xorg-x11-server-utils xorg-x11-fonts* xorg-x11-utils xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps tini && \
# RUN yum install -y -q libXtst dbus-x11 xorg-x11-xauth xorg-x11-xinit xdg-utils xorg-x11-server-utils && \
RUN dnf install --nodocs -y -q \
    gtk3 \
    tigervnc-server \
    xrdp \
    xorgxrdp \
    supervisor && \
    dnf clean all -y -q && \
    rm -rf /var/cache/dnf

USER ${USER}

VOLUME ["/home/$USER/apiprojects"]