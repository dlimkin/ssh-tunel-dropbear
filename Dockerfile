FROM alpine:3.22

# Default user
ENV DEFAULT_USER=tunnel

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY motd.txt /etc/motd
RUN chmod +x /docker-entrypoint.sh

# Install Dropbear and basic tools and create Default user
RUN apk add --no-cache dropbear shadow \
    && adduser -D -s /bin/ash ${DEFAULT_USER} \
    && mkdir -p /home/${DEFAULT_USER}/.ssh \
    && chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}/.ssh \
    && chmod 700 /home/${DEFAULT_USER}/.ssh

# Volumes for keys
VOLUME ["/home", "/etc/dropbear"]

# Expose SSH and HTTP ports
EXPOSE 22 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
