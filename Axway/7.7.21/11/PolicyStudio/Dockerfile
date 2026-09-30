# Get the centos, latest is ok as it is a dev environment.
FROM lacg/axway_devtools_gui:8 as intermediate

# Maintainer
LABEL maintainer="lgarcia@axway.com"

# Axway runtime distribution filename.
ARG BUILD_DATE
ARG BUILD_VERSION
ARG USER=axway
# ARG USER=developer

# Identifying intermediate multi-stage build to be removed after the build.
ARG BUILD_ID=1.0
LABEL stage=intermediate
LABEL build=$BUILD_ID

# Identifying meta-labels for build.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_policystudio:7.7.20211130"
LABEL org.label-schema.description="Policy Studio for 7.7.20211130."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -d -e DISPLAY={your_ip}:0 -e COMMAND=/opt/axway/policystudio/policystudio -e MAGIC_COOKIE={your_magic_cookie} -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/axway/apiprojects/7.7.20211130:/home/$USER/apiprojects -v ~/axway/policystudio/7.7.20211130/configuration:/opt/axway/policystudio/configuration lacg/axway_policystudio:7.7.20211130 /home/$USER/execute"

USER root

# Copy API Gateway installer to /opt/files.
COPY --chown=$USER:$USER ./Installers/APIGateway_7.7.20211130_Install_linux-x86-64_BN02.run /opt/files/

# Install the Policy Studio, change its memory size and then change the ownership to axway.
RUN chmod +x /opt/files/APIGateway_7.7.20211130_Install_linux-x86-64_BN02.run && \
    /opt/files/APIGateway_7.7.20211130_Install_linux-x86-64_BN02.run  --mode "unattended" --setup_type "advanced" --enable-components "policystudio" --disable-components "nodemanager,apigateway,apimgmt,analytics,cassandra,qstart,configurationstudio,packagedeploytools" --prefix "/opt/axway/" && \
    sed -i 's/768m/1756m/g' /opt/axway/policystudio/policystudio.ini && \
    mkdir -p /opt/axway/policystudio/configuration/login && \
    mkdir -p /home/$USER/apiprojects && \
    chown -R $USER:$USER /opt && \
    chown -R $USER:$USER /home/$USER && \
    rm /opt/files/APIGateway_7.7.20211130_Install_linux-x86-64_BN02.run

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/axway/policystudio"

COPY --chown=$USER:$USER ./Scripts/PolicyStudio.desktop /home/${USER}/Desktop/
COPY --chown=$USER:$USER ./Scripts/PolicyStudio.desktop /opt/axway/policystudio/

RUN chmod +x /opt/axway/policystudio/PolicyStudio.desktop && \
    chmod +x /home/${USER}/Desktop/PolicyStudio.desktop

USER ${USER}

# To keep the image size smaller using multi-stage build.
FROM lacg/axway_devtools_gui:8

COPY --from=intermediate /opt/axway /opt/axway

VOLUME ["/opt/axway/policystudio/configuration/login"]

# CMD [ '/opt/axway/policystudio/policystudio && exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"' ]

# ENTRYPOINT [ '/opt/axway/policystudio/policystudio && exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"' ]