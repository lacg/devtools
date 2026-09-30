FROM lacg/axway_devtools_base:7

# Maintainer
LABEL maintainer="lgarcia@axway.com"

# Axway runtime distribution filename.
ARG BUILD_DATE
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="lacg/axway_devtools_base_apim:7"
LABEL org.label-schema.description="Baseline for the Axway API web sites. Containts net-tools and Python3 libraries."
LABEL org.label-schema.url="http://support.axway.com/"
LABEL org.label-schema.vendor="Axway Inc."
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker container run -it lacg/axway_devtools_base_apim:7 bash"

# Update OS and libraries needed by tools.
RUN sudo yum update -y -q && \
    sudo yum install -y -q -e 0 net-tools python3 pip3 && \
    sudo yum -y clean all && \
    sudo rm -rf /var/cache/yum && \
    sudo ln -fs /usr/bin/python3 /usr/bin/python && \
    pip3 install --user pyyaml
