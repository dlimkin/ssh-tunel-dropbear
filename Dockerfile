# Alpine as base
FROM alpine:3.22

# Set default username via environment variable
# Default user will be "tunnel"
ENV USER_NAME=tunnel

# Allow mounting .ssh via Docker volume
VOLUME ["/home/$USER_NAME/.ssh"]



COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Install Dropbear and necessary tools
RUN apk add --no-cache dropbear shadow libcap

RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/dropbear

# Generate host keys during build
RUN mkdir -p /etc/dropbear && \
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key && \
    dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key && \
    dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key

# Create the SSH user
RUN adduser -D -s /bin/ash $USER_NAME

# Create .ssh directory for authorized_keys
RUN mkdir -p /home/$USER_NAME/.ssh && chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh

# Expose SSH port (for tunneling) and HTTP port (for reverse tunnel)
EXPOSE 22 80
# Run Dropbear in foreground
ENTRYPOINT ["/docker-entrypoint.sh"]
