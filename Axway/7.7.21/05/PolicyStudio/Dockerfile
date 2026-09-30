# Get the centos, latest is ok as it is a dev environment.
FROM lacg/axway_devtools_base:7 as intermediate

# Maintainer
LABEL maintainer="lgarcia@axway.com"

# Axway runtime distribution filename.
ARG BUILD_DATE
ARG BUILD_VERSION
# ARG DEFAULT_USER=axway
ARG DEFAULT_USER=developer

# Identifying intermediate multi-stage build to be removed after the build.
ARG BUILD_ID=1.0
LABEL stage=intermediate
LABEL build=$BUILD_ID

# Identifying meta-labels for build.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_policystudio:7.7.20210530"
LABEL org.label-schema.description="Policy Studio for 7.7.20210530."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -d -e DISPLAY={your_ip}:0 -e COMMAND=/opt/axway/policystudio/policystudio -e MAGIC_COOKIE={your_magic_cookie} -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/axway/apiprojects/7.7.20210530:/home/$DEFAULT_USER/apiprojects -v ~/axway/policystudio/7.7.20210530/configuration:/opt/axway/policystudio/configuration lacg/axway_policystudio:7.7.20210530 /home/$DEFAULT_USER/execute"

# Copy API Gateway installer to /opt/files.
COPY --chown=$DEFAULT_USER:$DEFAULT_USER ./Installers/APIGateway_7.7.20210530_Install_linux-x86-64_BN02.run /opt/files/

# Install the Policy Studio, change its memory size and then change the ownership to axway.
RUN sudo chmod +x /opt/files/APIGateway_7.7.20210530_Install_linux-x86-64_BN02.run && \
    sudo /opt/files/APIGateway_7.7.20210530_Install_linux-x86-64_BN02.run  --mode "unattended" --setup_type "advanced" --enable-components "policystudio" --disable-components "nodemanager,apigateway,apimgmt,analytics,cassandra,qstart,configurationstudio,packagedeploytools" --prefix "/opt/axway/" && \
    sudo sed -i 's/768m/1756m/g' /opt/axway/policystudio/policystudio.ini && \
    sudo mkdir -p /opt/axway/policystudio/configuration/login && \
    sudo chown -R $DEFAULT_USER:$DEFAULT_USER /opt && \
    sudo rm /opt/files/APIGateway_7.7.20210530_Install_linux-x86-64_BN02.run

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/axway/policystudio"

COPY --chown=$DEFAULT_USER:$DEFAULT_USER ./Scripts/PolicyStudio.desktop /home/${DEFAULT_USER}/Desktop/
COPY --chown=$DEFAULT_USER:$DEFAULT_USER ./Scripts/PolicyStudio.desktop /opt/axway/policystudio/

RUN sudo chmod +x /opt/axway/policystudio/PolicyStudio.desktop && \
    sudo chmod +x /home/${DEFAULT_USER}/Desktop/PolicyStudio.desktop

# To keep the image size smaller using multi-stage build.
FROM lacg/axway_devtools_base:7

COPY --from=intermediate /opt/axway /opt/axway

WORKDIR /home/$DEFAULT_USER

VOLUME ["/opt/axway/policystudio/configuration/login"]

CMD [ "/opt/axway/policystudio/policystudio" ]