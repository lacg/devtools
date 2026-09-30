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
LABEL org.label-schema.name="lacg/axway_esexplorer:7.5.2.5"
LABEL org.label-schema.description="ES Explorer for 7.5.2.5."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run - -d -e DISPLAY={your_ip}:0 -e COMMAND=/home/axway/es -e MAGIC_COOKIE={your_magic_cookie} -v /tmp/.X11-unix:/tmp/.X11-unix lacg/axway_esexplorer:7.5.2.5 /home/axway/execute"

# Copy API Gateway installer to /opt/files.
COPY --chown=axway:axway ./Installers/APIGateway_7.5.2_*linux-x86-64* /opt/files/

# Install the devtools, remove all unneeded files and then change the ownership to axway.
# Update fails, because it can't update the Entity Store of the node manager, so we just ignore it.
RUN sudo chmod +x /opt/files/APIGateway_7.5.2_Install_linux-x86-64_BN201610062_200320161145.run && \
    sudo /opt/files/APIGateway_7.5.2_Install_linux-x86-64_BN201610062_200320161145.run --mode "unattended" --setup_type "advanced" --enable-components "packagedeploytools" --disable-components "policystudio,configurationstudio,nodemanager,apigateway,apimgmt,analytics,cassandra,qstart,apitester" --prefix "/opt/axway/" && \
    sudo rm -rf /opt/axway/apigateway/apigateway/system/lib/modules /opt/axway/apigateway/apigateway/system/lib/jython /opt/axway/apigateway/apigateway/platform/jre /opt/axway/apigateway/apigateway/upgrade && \
    sudo tar xf /opt/files/APIGateway_7.5.2_SP5_Core_linux-x86-64_BN2017072817_200320145909.tar -C /opt/axway/apigateway/ && \
    sudo chown -R axway:axway /opt && \
    sudo chmod +x /opt/axway/apigateway/apigw_sp_post_install.sh && \
    sudo /opt/axway/apigateway/apigw_sp_post_install.sh -s 2> /dev/null; exit 0 && \
    sudo rm -rf /opt/files/APIGateway_7.5.2* \
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