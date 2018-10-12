# Start with an Alpine-based Python image
FROM python:alpine3.7

# Add our user
RUN useradd icanhaz

# Set a more helpful shell prompt
ENV PS1='[\u@\h \W]\$ '

# Update and upgrade all installed packages. Add some new ones:
#    curl: self-healthchecks
#    libssl1.0: being an HTTPS server
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        curl \
        libssl1.0 \
        traceroute && \
    mkdir -p /app

# Set up a suid version of traceroute owned by root to enable icanhaztrace.com features
RUN cp /bin/traceroute /bin/traceroute-suid && \
    chown root:root /bin/traceroute-suid && \
    chmod u+s /bin/traceroute-suid

# Equivalent to `cd /app`
WORKDIR /app

# Our code serves HTTP on port 5000. The dockervisor will expose this port
# to the world as some other number, set at run time.
EXPOSE 5000

# When a container based on this image is executed, initialize the needed files and start our app
CMD ["gunicorn", "-c", "gunicorn.py", "icanhaz.app:app"]

# Pull in a version at build time
ARG version

# Set image metadata
LABEL name="ICANHAZ Container" \
      maintainer="Major Hayden" \
      author="Major Hayden" \
      license="Apache 2.0" \
      version="${version}"


# Copy our files into the container
ADD . .

# If our python package is installable, install system packages that are needed by some python libraries to compile
# successfully, then install our python package. Finally, delete the temporary system packages.
RUN \
if [ -f setup.py ]; then \
apk add --no-cache --virtual .build-deps \
    build-base \
    python3-dev \
    libffi-dev \
    openssl-dev && \
    pip install --no-cache-dir --compile --editable . && \
    apk del .build-deps \
;fi

# Export the version as an environment variable for possible logging/debugging
ENV API_VER ${version}

# This container performs its own healthchecks by attempting to connect to
# our HTTP server and GET the healthcheck endpoint.
# Example of a successful response:
# {"status":200,"content":null,"message":"NAAS is running.","request_id":"2bef8456-c25b-4884-9250-9a0eeb4b4654"}
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD [ $APP_ENVIRONMENT = "staging" ] && staging="-staging"; \
    curl -k -f -H "Host: icanhazip${staging}.com" https://127.0.0.1:5000/
