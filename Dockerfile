FROM fedora:22

RUN yum -y install httpd mod_wsgi python-flask traceroute && yum clean all
RUN mkdir -vp /var/www/html/icanhaz-app/icanhaz/

RUN useradd icanhaz

# Set up a suid version of traceroute owned by root to enable icanhaztrace.com features
RUN cp /bin/traceroute /bin/traceroute-suid && \
    chown root:root /bin/traceroute-suid && \
    chmod u+s /bin/traceroute-suid

# Configure the wsgi application
ADD docker/icanhaz.wsgi /var/www/html/icanhaz-app/icanhaz.wsgi
ADD docker/icanhaz-app.conf /etc/httpd/conf.d/icanhaz-app.conf
ADD docker/icanhaz-config.stub /etc/httpd/conf.d/icanhaz-config.stub
ADD docker/icanhaz.py /var/www/html/icanhaz-app/icanhaz/icanhaz.py
RUN echo "ServerTokens Prod" >> /etc/httpd/conf.d/servertokens.conf
RUN echo "ServerName icanhazip.com" >> /etc/httpd/conf.d/servername.conf

ENTRYPOINT ["/usr/sbin/httpd"]
EXPOSE 80
CMD ["-D", "FOREGROUND"]




########################
#  Base Image Section  #
########################
#
# Creates an image with the common requirements for a flask app pre-installed


# Start with an Alpine-based Python image
FROM python:alpine3.7

# Set a more helpful shell prompt
ENV PS1='[\u@\h \W]\$ '

# Update and upgrade all installed packages. Add some new ones:
#    ca-certificates: connecting to HTTPS sites
#    curl: self-healthchecks
#    libssl1.0: being an HTTPS server
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        ca-certificates \
        curl \
        libssl1.0 && \
    mkdir -p /app

# Equivalent to `cd /app`
WORKDIR /app

# Our code serves HTTP on port 5000. The dockervisor will expose this port
# to the world as some other number, set at run time.
EXPOSE 5000

# When a container based on this image is executed, initialize the needed files and start our app
CMD ["python", "initialization.py"]

# Pull in a version at build time
ARG version

# Set image metadata
LABEL name="ICANHAZ Container" \
      maintainer="Major Hayden" \
      author="Major Hayden" \
      license="Apache 2.0" \
      version="${version}"


#####################
#  ONBUILD Section  #
#####################
#
# ONBUILD commands take effect when another image is built using this one as a base.
# Ref: https://docs.docker.com/engine/reference/builder/#onbuild
#
# Example Dockerfile that builds from this image:
#
# FROM nsi-docker-local.artifacts.rackspace.net/nsi_python3_base:latest
# LABEL name="my_app" author="me <me@rackspace.com>"
# HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
#     CMD [ $APP_ENVIRONMENT = "staging" ] && staging="-staging"; \
#     curl -k -f -H "Host: my_app${staging}.nsi.rackspace.com" https://127.0.0.1:5000/healthcheck/
#
# And that's it! The base container should have all your dependencies and ssl certs pre-installed,
# and will copy your code over when used as a base with the "FROM" directive.

# Copy our files into the container
ONBUILD ADD . .

# If our python package is installable, install system packages that are needed by some python libraries to compile
# successfully, then install our python package. Finally, delete the temporary system packages.
ONBUILD RUN \
if [ -f setup.py ]; then \
apk add --no-cache --virtual .build-deps \
    build-base \
    python3-dev \
    libffi-dev \
    openssl-dev && \
    pip install --no-cache-dir --compile --editable . && \
    apk del .build-deps \
;fi

# Pull in a version at build time
ONBUILD ARG version

# Set Docker image metadata
ONBUILD LABEL \
    maintainer="Network Security Infrastructure <nsi@rackspace.com>" \
    license="GPLv3+" \
    version="${version}"

# Export the version as an environment variable for possible logging/debugging
ONBUILD ENV API_VER ${version}

# Set Docker image metadata
LABEL name="NAAS API Image" \
      author="Brett Lykins <brett.lykins@rackspace.com>"

# This container performs its own healthchecks by attempting to connect to
# our HTTP server and GET the healthcheck endpoint.
# Example of a successful response:
# {"status":200,"content":null,"message":"NAAS is running.","request_id":"2bef8456-c25b-4884-9250-9a0eeb4b4654"}
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD [ $APP_ENVIRONMENT = "staging" ] && staging="-staging"; \
    curl -k -f -H "Host: naas${staging}.nsi.rackspace.com" https://127.0.0.1:5000/healthcheck/
