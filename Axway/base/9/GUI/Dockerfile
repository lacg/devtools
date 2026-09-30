ARG BASE_IMAGE=lacg/axway_devtools_base
ARG BASE_IMAGE_VERSION=9

FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}

# Maintainer
LABEL maintainer="lgarcia@axway.com"

ARG BUILD_DATE
ARG BUILD_VERSION
ARG USER=axway
ARG VNC_RESOLUTION=1920x1080
ARG VNC_PASSWORD="axway1"
ARG KASMVNC_VERSION=1.4.0
ENV KASMVNC_VERSION=${KASMVNC_VERSION}

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_devtools_gui:9"
LABEL org.label-schema.description="Baseline for the Axway API developer tools using Rocky Linux 9 with KasmVNC."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -it lacg/axway_devtools_gui:9 bash"

USER root

# Enable CodeReady Builder (CRB) for additional Perl packages required by KasmVNC.
RUN dnf config-manager --set-enabled crb

# Install window manager, GUI libraries, fonts, dbus, and supervisor.
# KasmVNC replaces TigerVNC + websockify + noVNC with a single browser-native server.
RUN dnf install -y --nodocs \
    openbox \
    xterm \
    supervisor \
    dbus-x11 \
    gtk3 \
    xorg-x11-server-utils \
    xorg-x11-fonts-Type1 \
    xorg-x11-fonts-misc \
    liberation-fonts \
    dejavu-sans-fonts \
    dejavu-serif-fonts \
    dejavu-sans-mono-fonts \
    at-spi2-atk \
    at-spi2-core \
    wmctrl \
    perl-DateTime-TimeZone \
    perl-Switch \
    perl-YAML-Tiny && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Install KasmVNC — a container-native VNC server with a built-in browser client.
# Replaces the TigerVNC + websockify + noVNC stack from base/8.
# Web UI is served on port 6901 (no separate websockify needed).
# Selects the correct RPM arch: aarch64 on ARM64 hosts, x86_64 otherwise.
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then \
        KASMVNC_ARCH=aarch64; \
    else \
        KASMVNC_ARCH=x86_64; \
    fi && \
    dnf install -y \
        https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_oracle_9_${KASMVNC_VERSION}_${KASMVNC_ARCH}.rpm && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Pre-create /tmp/.X11-unix with correct permissions so non-root Xvnc can write to it.
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && \
    mkdir -p /var/log/supervisor

# Copy supervisord and KasmVNC configuration.
COPY ./etc/supervisord.conf      /etc/supervisord.conf
COPY ./etc/supervisord.d/        /etc/supervisord.d/
COPY ./etc/kasmvnc.yaml          /etc/kasmvnc/kasmvnc.yaml

# Copy KasmVNC per-user config (brute-force protection, HTTP mode).
# Placed here (as root) so we can chown it; ownership fixed below after USER axway block.
COPY --chown=${USER}:${USER} ./etc/kasmvnc.yaml /home/${USER}/.vnc/kasmvnc.yaml

# Inject the username into supervisord entries.
RUN sed -i "s/USERNAME/${USER}/g" /etc/supervisord.d/*.ini

USER ${USER}

# Configure KasmVNC auth, VNC directory and Openbox autostart.
# kasmvncpasswd creates ~/.kasmpasswd used by KasmVNC's in-page login form.
# HTTP BasicAuth is disabled via -DisableBasicAuth 1 so the browser shows
# KasmVNC's own login form instead of a browser popup (single sign-in).
RUN mkdir -p /home/${USER}/.vnc \
             /home/${USER}/.config/openbox && \
    # Set KasmVNC login credentials (username = system user, password = VNC_PASSWORD).
    echo -e "${VNC_PASSWORD}\n${VNC_PASSWORD}\n" | kasmvncpasswd -u ${USER} -r -w -o /home/${USER}/.kasmpasswd && \
    # KasmVNC xstartup — openbox is managed by supervisord so this is a fallback only.
    echo '#!/bin/bash' > /home/${USER}/.vnc/xstartup && \
    chmod +x /home/${USER}/.vnc/xstartup && \
    # Openbox autostart: set neutral background and disable screensaver where supported.
    echo "xsetroot -gray" >> /home/${USER}/.config/openbox/autostart && \
    echo "xset s off || true" >> /home/${USER}/.config/openbox/autostart && \
    echo "xset s noblank || true" >> /home/${USER}/.config/openbox/autostart && \
    # Auto-maximize the first window that opens (Policy Studio).
    echo "(while ! wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz 2>/dev/null; do sleep 2; done) &" >> /home/${USER}/.config/openbox/autostart

VOLUME ["/home/${USER}/apiprojects"]

# KasmVNC browser UI port.
EXPOSE 6901

# kasmvncpasswd creates .kasmpasswd as root even when run as USER axway.
# Fix ownership so Xvnc (running as axway) can read it for HTTP BasicAuth.
USER root
RUN chown ${USER}:${USER} /home/${USER}/.kasmpasswd

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
