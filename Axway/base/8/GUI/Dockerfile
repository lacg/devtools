ARG BASE_IMAGE=lacg/axway_devtools_x11
ARG BASE_IMAGE_VERSION=8

# Get the centos, latest is ok as it is a dev environment.
FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}

# Maintainer
LABEL maintainer="lgarcia@axway.com"

# Axway runtime distribution filename.
ARG BUILD_DATE
ARG BUILD_VERSION
ARG USER=axway

# Set the subject of the self-signed SSL-certificate
ARG KEYSUBJECT=/C=US/ST=Arizona/L=Scottsdale/O=Axway/OU=ACS/CN=vnc.axway.io
# Set to "true" to force encryption on TigerVNC-server over TCP/5901. Note: this breaks noVNC and some VNC clients.
ARG VNCTLS=false
ARG VNC_PASSWORD="axway"

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_devtools_gui:8"
LABEL org.label-schema.description="Baseline for the Axway API developer tools using CentOS 8 with VNC."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -it lacg/axway_devtools_gui:8 bash"

USER root

# Include the X-Window libraries.
# First we enable the PowerTools.
# https://linuxhint.com/enable-powertools-repository-centos/
# RUN dnf -y -q install dnf-plugins-core && \
#    dnf -y -q install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
#    dnf config-manager --set-enabled powertools && \
    # Install, configure and start SSHD needed for X11 access.
#    yum install -y -q openssh-server && \
#    ssh-keygen -A && \
#    /usr/sbin/sshd && \
#    yum install -y -q gtk3 xorg-x11-xauth xorg-x11-fonts* xorg-x11-utils xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps && \
# RUN yum groupinstall -y -q base-x && \
#    yum install -y -q xrdp xfce4-terminal && \
    # It's a lightweight Linux terminal with Unicode support.
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    dnf install --nodocs -y -q \
#    rxvt-unicode \
    openbox \
    https://cbs.centos.org/kojifiles/packages/novnc/1.3.0/1.el8/noarch/novnc-1.3.0-1.el8.noarch.rpm \
    https://cbs.centos.org/kojifiles/packages/python-websockify/0.9.0/1.el8/noarch/python3-websockify-0.9.0-1.el8.noarch.rpm && \
    dnf clean all -y -q && \
    rm -rf /var/cache/dnf

# Copy configuration files for Supervisord.
COPY ./etc/xrdp/xrdp.ini     /etc/xrdp/xrdp.ini
COPY ./etc/xrdp/sesman.ini   /etc/xrdp/sesman.ini
COPY ./etc/supervisord.conf  /etc/supervisord.conf
COPY ./etc/supervisord.d/*   /etc/supervisord.d/

# Fix to allow xrdp to start X from a TTY thats not a physical one.
RUN echo "allowed_users = anybody" >> /etc/X11/Xwrapper.config && \
    # Set username in Supervisord configuration for TigerVNC.
    sed -i s/USERNAME/${USER}/g /etc/supervisord.d/vncserver.ini && \
    # If VNCTLS is set to true, force use of encryption by TigerVNC server.
    if ${VNCTLS} ; then sed -i 's/-fg/-fg -SecurityTypes=VeNCrypt,TLSVnc/' /etc/supervisord.d/vncserver.ini; fi && \
    # Create self-signed certificate for noVNC.
    openssl req -x509 -nodes -newkey rsa:4096 -days 3650 \
    -keyout /etc/pki/tls/certs/novnc.pem -out /etc/pki/tls/certs/novnc.pem  \
    -subj "${KEYSUBJECT}" && \
    # Set openbox background to gray instead of solid black.
    echo "xsetroot -gray" >> /etc/xdg/openbox/autostart

# Only if you install a Chrome based browser.
# Fix for Chromium browser to not use CGROUP sandboxing which does not work in containers.
# RUN if [ ${BROWSER} = "chromium" ] ; then sed -i 's/--auto-ssl-client-auth "/--auto-ssl-client-auth --no-sandbox "/' /usr/lib64/chromium-browser/chromium-browser.sh; fi

# Run commands as non-root user to prevent having to set a lot of permissions and ownership.
USER ${USER}

# Configure password for TigerVNC and start openbox on TigerVNC startup.
RUN mkdir /home/${USER}/.vnc && echo "${VNC_PASSWORD}}" | /usr/bin/vncpasswd -f > /home/${USER}/.vnc/passwd && chmod 600 /home/${USER}/.vnc/passwd && \
    echo "openbox-session" > /home/${USER}/.vnc/xstartup && chmod +x /home/${USER}/.vnc/xstartup && \
    if [[ -z ${VNC_PASSWORD} ]] ; then vncserver -SecurityTypes None ; fi && \
    # Configure xrdp to start openbox on user login.
    echo "exec openbox-session" > /home/${USER}/startwm.sh && \
    chmod +x /home/${USER}/startwm.sh

# Espose RDP, VNC and noVNC ports.
EXPOSE 3389
EXPOSE 5901
EXPOSE 6901

VOLUME ["/home/${USER}/apiprojects"]

# Start supervisord as root.
USER root
CMD ["sudo", "/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]