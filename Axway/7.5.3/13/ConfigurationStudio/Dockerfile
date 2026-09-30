# Get the centos, latest is ok as it is a dev environment.
FROM lacg/axway_devtools_base:7 as intermediate

# Maintainer
LABEL maintainer="lgarcia@axway.com"

# Axway runtime distribution filename.
ARG BUILD_DATE
ARG BUILD_VERSION

# Identifying intermediate multi-stage build to be removed after the build.
ARG BUILD_ID=1.0
LABEL stage=intermediate
LABEL build=$BUILD_ID

# Identifying meta-labels for build.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_configurationstudio:7.5.3.13"
LABEL org.label-schema.description="Configuration Studio for 7.5.3 SP13."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run - -d -e DISPLAY={your_ip}:0 -e COMMAND=/opt/axway/configurationstudio/configurationstudio -e MAGIC_COOKIE={your_magic_cookie} -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/axway/apiprojects/7.5.3.13:/home/axway/apiprojects -v ~/axway/configurationstudio/7.5.3.13/configuration:/opt/axway/configurationstudio/configuration lacg/axway_configurationstudio:7.5.3.13 /home/axway/execute"

# Copy API Gateway installer to /opt/files.
COPY --chown=axway:axway ./Installers/APIGateway_7.5.3_*linux-x86-64* /opt/files/

# Install the Configuration Studio, change its memory size and then change the ownership to axway.
RUN sudo chmod +x /opt/files/APIGateway_7.5.3_Install_linux-x86-64_BN8.run && \
    sudo /opt/files/APIGateway_7.5.3_Install_linux-x86-64_BN8.run --mode "unattended" --setup_type "advanced" --enable-components "configurationstudio" --disable-components "policystudio,packagedeploytools,nodemanager,apigateway,apimgmt,analytics,cassandra,qstart,apitester" --prefix "/opt/axway/" && \
    sudo tar xf /opt/files/APIGateway_7.5.3_SP13_ConfigurationStudio_linux-x86-64_BN202005012.tar -C /opt/axway/configurationstudio/ && \
    sudo sed -i 's/768m/1268m/g' /opt/axway/configurationstudio/configurationstudio.ini && \
    sudo chown -R axway:axway /opt && \
    sudo rm /opt/files/APIGateway_7.5.3_*

# To keep the image size smaller using multi-stage build.
FROM lacg/axway_devtools_base:7

COPY --from=intermediate /opt/axway /opt/axway

VOLUME ["/opt/axway/configurationstudio/configuration"]