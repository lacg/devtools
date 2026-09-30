# Get the centos, latest is ok as it is a dev environment.
FROM lacg/axway_devtools_base_apim:7 as intermediate

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
LABEL org.label-schema.name="lacg/axway_gateway:7.6.2.4"
LABEL org.label-schema.description="API Gateway for 7.6.2.4."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -d -p 8090:8090 -p 8080:8080 lacg/axway_gateway:7.6.2.4 /home/axway/hi"

# Copy API Gateway installer to /opt/files.
COPY --chown=axway:axway ./Installers/APIGateway_7.6.2_SP4_Install_linux-x86-64_BN20190719.run /opt/files/
COPY --chown=axway:axway ./Licenses/API7.6Temp.lic /opt/files/apim.lic

# Install the devtools and then change the ownership to axway and remove all unneeded files.
# Update fails, because it can't update the Entity Store of the node manager, so we just ignore it.
RUN sudo chmod +x /opt/files/APIGateway_7.6.2_SP4_Install_linux-x86-64_BN20190719.run && \
    # Install the API Gateway and Nodemanager.
    sudo /opt/files/APIGateway_7.6.2_SP4_Install_linux-x86-64_BN20190719.run --mode "unattended" --setup_type "advanced" --enable-components "nodemanager,apigateway,apimgmt,packagedeploytools" --licenseFilePath "/opt/files/apim.lic" --disable-components "policystudio,configurationstudio,analytics,cassandra,qstart,apitester" --prefix "/opt/axway/" && \
    sudo chown -R axway:axway /opt && \
    sudo chown -R axway:axway /home/axway && \
    sudo rm -rf /opt/files/APIGateway_7.6.2_SP4_Install_linux-x86-64_BN20190719.run \
            /opt/axway/apigateway/Axway-installLog.log \
            /opt/axway/apigateway/uninstall* \
            /opt/axway/apigateway/docs \
            /opt/axway/apigateway/Linux.x86_64/bin/wkhtmltopdf \
            /opt/axway/apigateway/conf/plugin/mcafee

RUN /opt/axway/apigateway/posix/bin/managedomain -i --anm_host=localhost && \
    /opt/axway/apigateway/posix/bin/nodemanager -d && \
    sudo /opt/axway/apigateway/posix/bin/managedomain -c -g group -n gateway --username=admin --password=changeme --host=localhost && \
    /opt/axway/apigateway/posix/bin/nodemanager -k && \
    sudo chown -R axway:axway /opt/axway/apigateway/

# To keep the image size smaller using multi-stage build.
FROM lacg/axway_devtools_base_apim:7

COPY --from=intermediate /opt/axway /opt/axway

ENTRYPOINT ["/home/axway/daemon"]