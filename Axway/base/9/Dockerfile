ARG BASE_IMAGE=rockylinux
ARG BASE_IMAGE_VERSION=9

FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}

# Maintainer
LABEL maintainer="lgarcia@axway.com"

ARG BUILD_DATE
ARG BUILD_VERSION
ARG USER=axway
ARG TZ=America/Phoenix

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_devtools_base:9"
LABEL org.label-schema.description="Baseline for the Axway API developer tools using Rocky Linux 9."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -it lacg/axway_devtools_base:9 bash"

# Set time zone
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# Update OS and install base dependencies.
# libnsl  provides libnsl.so.1 — required by Policy Studio and other Axway binaries.
# libnsl2 provides libnsl.so.2 — required by Axway installers on RHEL 9.
RUN dnf install -y --nodocs epel-release && \
    dnf install -y --nodocs \
    glibc-langpack-en \
    libnsl \
    libnsl2 \
    tini \
    sudo && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Create axway user with sudo access.
# /opt/files is used for installer and license staging.
# libnsl2 on Rocky 9 ships libnsl.so.3, but Axway tools need libnsl.so.1.
# This symlink is the standard workaround for legacy apps on RHEL 9.
RUN ln -s /usr/lib64/libnsl.so.3 /usr/lib64/libnsl.so.1

RUN useradd -m ${USER} && echo "${USER}:${USER}" | chpasswd && \
    usermod -aG wheel ${USER} && \
    mkdir -p /opt/files && \
    chown -R ${USER}:${USER} /opt && \
    echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers && \
    echo "alias ll='ls -larth'" >> /etc/profile.d/aliases.sh && \
    chmod +x /etc/profile.d/aliases.sh && \
    touch /home/${USER}/.Xauthority && \
    chown -R ${USER}:${USER} /home/${USER}

COPY --chown=${USER}:${USER} ./Scripts/* /home/${USER}/

USER ${USER}
WORKDIR /home/${USER}
ENV HOME=/home/${USER}

# Required by Axway APIM components.
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/axway/apigateway/Linux.x86_64/lib/"
