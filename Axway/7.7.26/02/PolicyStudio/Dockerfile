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
LABEL org.label-schema.name="lacg/axway_policystudio:7.7.0.20260228"
LABEL org.label-schema.description="Policy Studio for Axway API Gateway 7.7.0.20260228."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION

USER root

# Copy the installer into the build context.
# Place the installer at: ./Installers/APIGateway_7.7.20260228_Install_linux-x86-64_BN03.run
# The Installers/ directory is git-ignored — copy the file manually before building.
COPY --chown=${USER}:${USER} ./Installers/APIGateway_7.7.20260228_Install_linux-x86-64_BN03.run /opt/files/

# Install Policy Studio only (no nodemanager, apigateway, etc.).
# Bumping JVM heap to 2048m for the 2026 release.
RUN chmod +x /opt/files/APIGateway_7.7.20260228_Install_linux-x86-64_BN03.run && \
    /opt/files/APIGateway_7.7.20260228_Install_linux-x86-64_BN03.run \
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
    rm /opt/files/APIGateway_7.7.20260228_Install_linux-x86-64_BN03.run

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

# Policy project files — bind-mount to ~/axway/7.7.0.20260228/apiprojects on the host
# for direct access from macOS Finder or your IDE.
VOLUME ["/home/${USER}/apiprojects"]

# Policy Studio saved connections and login configuration.
VOLUME ["/opt/axway/policystudio/configuration/login"]

# License file volume — mount an Axway license here if required.
# Docker:  -v ~/axway/licenses:/opt/axway/policystudio/conf/licenses:ro
# K8s:     mount secret 'axway-license' at /opt/axway/policystudio/conf/licenses
VOLUME ["/opt/axway/policystudio/conf/licenses"]
