# Alpine as base
FROM alpine:3.22

# Install Dropbear SSH server
RUN apk add --no-cache dropbear

# Set default username via environment variable
# Default user will be "tunnel"
ENV USER_NAME=tunnel

# Create the SSH user
RUN adduser -D -s /bin/ash $USER_NAME

# Create .ssh directory for authorized_keys
RUN mkdir -p /home/$USER_NAME/.ssh && chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh

# Allow mounting authorized_keys via Docker secret or volume
VOLUME ["/home/$USER_NAME/.ssh/authorized_keys"]

# Generate host keys if not present
RUN dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key

# Expose SSH port (for tunneling) and HTTP port (for reverse tunnel)
EXPOSE 22 80

# Run Dropbear in foreground with logging to stderr
CMD ["/usr/sbin/dropbear", "-F", "-E", "-p", "22"]
