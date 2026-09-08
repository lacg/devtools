ARG BASE_IMAGE=lacg/axway_devtools_gui
ARG BASE_IMAGE_VERSION=9

# --- Stage 1: install Policy Studio into a clean layer ---
FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION} AS intermediate

LABEL maintainer="lgarcia@axway.com"

ARG BUILD_DATE
ARG BUILD_VERSION
ARG USER=axway

LABEL stage=intermediate
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_policystudio:7.7.0.20260830"
LABEL org.label-schema.description="Policy Studio for Axway API Gateway 7.7.0.20260830."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION

USER root

# Copy the installer into the build context.
# Place the installer at: ./Installers/APIGateway_7.7.20260830_Install_linux-x86-64_BN02.run
# The Installers/ directory is git-ignored — copy the file manually before building.
COPY --chown=${USER}:${USER} ./Installers/APIGateway_7.7.20260830_Install_linux-x86-64_BN02.run /opt/files/

# Install Policy Studio only (no nodemanager, apigateway, etc.).
# Bumping JVM heap to 2048m for the 2026-08 release.
RUN chmod +x /opt/files/APIGateway_7.7.20260830_Install_linux-x86-64_BN02.run && \
    /opt/files/APIGateway_7.7.20260830_Install_linux-x86-64_BN02.run \
        --mode "unattended" \
        --acceptGeneralConditions "yes" \
        --setup_type "advanced" \
        --enable-components "policystudio" \
        --disable-components "nodemanager,apigateway,apimgmt,analytics,cassandra,qstart,configurationstudio,packagedeploytools" \
        --prefix "/opt/axway/" && \
    sed -i 's/768m/2048m/g' /opt/axway/policystudio/policystudio.ini && \
    mkdir -p /opt/axway/policystudio/configuration/login && \
    mkdir -p /opt/axway/policystudio/conf/licenses && \
    mkdir -p /home/${USER}/apiprojects && \
    chown -R ${USER}:${USER} /opt && \
    chown -R ${USER}:${USER} /home/${USER} && \
    rm /opt/files/APIGateway_7.7.20260830_Install_linux-x86-64_BN02.run

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/axway/policystudio"

COPY --chown=${USER}:${USER} ./Scripts/PolicyStudio.desktop /home/${USER}/Desktop/
COPY --chown=${USER}:${USER} ./Scripts/PolicyStudio.desktop /opt/axway/policystudio/

RUN chmod +x /opt/axway/policystudio/PolicyStudio.desktop && \
    chmod +x /home/${USER}/Desktop/PolicyStudio.desktop

# --- Stage 2: final image (no installer cache) ---
FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}

ARG USER=axway

COPY --from=intermediate /opt/axway /opt/axway
COPY --from=intermediate /home/${USER}/Desktop /home/${USER}/Desktop

# Disable GTK's SVG icon loader (librsvg). Under QEMU user-mode emulation (Apple Silicon
# without Rosetta) librsvg segfaults while laying out the New Project wizard, taking
# Policy Studio down. Without the loader GTK simply skips SVG icons; Policy Studio's own
# icons are PNG and unaffected.
RUN mv /usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-svg.so \
       /usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-svg.so.disabled && \
    gdk-pixbuf-query-loaders-64 --update-cache

# Ship preference defaults (see Scripts/plugin_customization.ini) and point the Eclipse
# launcher at them. Program args must precede -vmargs in policystudio.ini.
COPY --chown=${USER}:${USER} ./Scripts/plugin_customization.ini /opt/axway/policystudio/plugin_customization.ini
RUN sed -i 's|^-vmargs$|-pluginCustomization\n/opt/axway/policystudio/plugin_customization.ini\n-vmargs|' /opt/axway/policystudio/policystudio.ini

# Add the Policy Studio supervisord entry so it is auto-started and supervised.
COPY ./etc/supervisord.d/policystudio.ini /etc/supervisord.d/policystudio.ini
RUN sed -i "s/USERNAME/${USER}/g" /etc/supervisord.d/policystudio.ini

# Openbox window rule: maximize Policy Studio automatically when it opens.
COPY --chown=${USER}:${USER} ./Scripts/openbox-rc.xml /home/${USER}/.config/openbox/rc.xml

# Fallback: poll until the Policy Studio window appears, then maximize it via wmctrl.
# Handles the race where Policy Studio opens before Openbox has applied its window rules.
RUN echo '(while ! wmctrl -l | grep -q "Policy Studio"; do sleep 1; done && wmctrl -r "Axway Policy Studio" -b add,maximized_vert,maximized_horz) &' \
    >> /home/${USER}/.config/openbox/autostart

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/axway/policystudio"

# Policy project files — bind-mount to ~/axway/7.7.0.20260830/apiprojects on the host
# for direct access from macOS Finder or your IDE.
VOLUME ["/home/${USER}/apiprojects"]

# Policy Studio saved connections and login configuration.
VOLUME ["/opt/axway/policystudio/configuration/login"]

# License file volume — mount an Axway license here if required.
# Docker:  -v ~/axway/licenses:/opt/axway/policystudio/conf/licenses:ro
# K8s:     mount secret 'axway-license' at /opt/axway/policystudio/conf/licenses
VOLUME ["/opt/axway/policystudio/conf/licenses"]
