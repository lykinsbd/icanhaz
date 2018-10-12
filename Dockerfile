# Start with an Alpine-based Python image
FROM python:alpine3.7

# Pull in a version at build time
ARG version

# Set image metadata
LABEL name="ICANHAZ Container" \
      maintainer="Major Hayden" \
      author="Major Hayden" \
      license="Apache 2.0" \
      version="${version}"

# Set a more helpful shell prompt
ENV PS1='[\u@\h \W]\$ '

# Update and upgrade all installed packages. Add some new ones:
#    curl: self-healthchecks
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        curl && \
    mkdir -p /app

# Equivalent to `cd /app`
WORKDIR /app

# Copy our files into the container
ADD . .

# Install our python package
RUN pip install --no-cache-dir --compile --editable .

# Export the version as an environment variable for possible logging/debugging
ENV API_VER ${version}

# This container performs its own healthchecks by attempting to connect to HTTP and GET "/"
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD [ $APP_ENVIRONMENT = "staging" ] && staging="-staging"; \
    curl -k -f -H "Host: icanhazip${staging}.com" http://127.0.0.1:5000/

# Our code serves HTTP on port 5000. Dockervisor will expose this port to the world as some other port, set at run time.
EXPOSE 5000

# When a container based on this image is executed, start our app in gunicorn
CMD ["gunicorn", "-c", "gunicorn.py", "icanhaz.icanhaz:app"]
