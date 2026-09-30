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
LABEL org.label-schema.name="lacg/axway_esexplorer:7.7.20.03"
LABEL org.label-schema.description="ES Explorer for 7.7.20.03."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run - -d -e DISPLAY={your_ip}:0 -e COMMAND=/home/axway/es -e MAGIC_COOKIE={your_magic_cookie} -v /tmp/.X11-unix:/tmp/.X11-unix lacg/axway_esexplorer:7.7.20.03 /home/axway/execute"

# Copy API Gateway installer to /opt/files.
COPY --chown=axway:axway ./Installers/APIGateway_7.7.20200330_Install_linux-x86-64_BN3.run /opt/files/

# Install the devtools, Policy Studio and Configuration Studio, change their memory size,
# remove all unneeded files and then change the ownership to axway.
RUN sudo chmod +x /opt/files/APIGateway_7.7.20200330_Install_linux-x86-64_BN3.run && \
    sudo /opt/files/APIGateway_7.7.20200330_Install_linux-x86-64_BN3.run --mode "unattended" --setup_type "advanced" --enable-components "packagedeploytools" --disable-components "policystudio,configurationstudio,nodemanager,apigateway,apimgmt,analytics,cassandra,qstart" --prefix "/opt/axway/" && \
    sudo chown -R axway:axway /opt && \
    sudo rm -rf /opt/files/APIGateway_7.7.20200330_Install_linux-x86-64_BN3.run \
            /opt/axway/apigateway/Axway-installLog.log \
            /opt/axway/apigateway/uninstall* \
            /opt/axway/apigateway/upgrade \
            /opt/axway/apigateway/docs \
            /opt/axway/apigateway/Linux.x86_64/bin/wkhtmltopdf \
            /opt/axway/apigateway/conf/plugin/mcafee

# To keep the image size smaller using multi-stage build.
FROM lacg/axway_devtools_base:7

COPY --from=intermediate /opt/axway /opt/axway

# Copy Entity Explorer script.
COPY --chown=axway:axway ./Scripts/es /home/axway/

RUN chmod +x /home/axway/es