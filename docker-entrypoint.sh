#!/bin/ash
set -e

# comment in English
# User name for SSH access, default is 'tunnel'
USER_NAME="${USER_NAME:-tunnel}"

# Path to the public SSH key file, default is empty
mkdir -p /home/${USER_NAME}/.ssh

# Environment variable for the public SSH key file
USE_KEY_AUTH=false
DROPBEAR_FLAGS="-F -E -a -p 22"

# Create user if it doesn't exist
if [ -n "$SSH_PUBLIC_KEY_FILE" ] && [ -f "$SSH_PUBLIC_KEY_FILE" ]; then
    cp "$SSH_PUBLIC_KEY_FILE" /home/${USER_NAME}/.ssh/authorized_keys
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.ssh
    chmod 700 /home/${USER_NAME}/.ssh
    chmod 600 /home/${USER_NAME}/.ssh/authorized_keys
    USE_KEY_AUTH=true
    echo "SSH public key loaded from $SSH_PUBLIC_KEY_FILE for user $USER_NAME"
elif [ -f "/home/${USER_NAME}/.ssh/authorized_keys" ]; then
    USE_KEY_AUTH=true
    echo "Using existing authorized_keys for user $USER_NAME"
fi

if [ "$USE_KEY_AUTH" = "true" ]; then
    # key exists - disable password authentication
    passwd -d "$USER_NAME"
    DROPBEAR_FLAGS="$DROPBEAR_FLAGS -s -g"
    echo "Password authentication disabled - using SSH key authentication only"
else
    # no key - enable password authentication
    PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)
    echo "$USER_NAME:$PASSWORD" | chpasswd
    echo "=========================================="
    echo "SSH LOGIN CREDENTIALS:"
    echo "Username: $USER_NAME"
    echo "Password: $PASSWORD"
    echo "=========================================="
    echo "Password authentication enabled"
fi

# Start Dropbear SSH server in the foreground
exec /usr/sbin/dropbear $DROPBEAR_FLAGS