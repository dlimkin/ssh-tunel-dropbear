#!/bin/ash
set -e

USER_NAME="${USER_NAME:-tunnel}"

USE_KEY_AUTH=false

DROPBEAR_FLAGS="-F -E -a -p 22"

# Ensure user exists
if ! id "$USER_NAME" >/dev/null 2>&1; then
    echo "Creating user: $USER_NAME"
    adduser -D -s /bin/ash "$USER_NAME"

    # Ensure .ssh exists
    mkdir -p /home/${USER_NAME}/.ssh
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.ssh
    chmod 700 /home/${USER_NAME}/.ssh
fi

# --- Host keys persistence ---
if [ ! -f /etc/dropbear/dropbear_rsa_host_key ]; then
    echo "Generating Dropbear host keys..."
    mkdir -p /etc/dropbear
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key > /dev/null 2>&1
    dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key > /dev/null 2>&1
    dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key > /dev/null 2>&1
else
    echo "Using existing Dropbear host keys"
fi

# --- Public key authentication setup ---
if [ -n "$SSH_PUBLIC_KEY_FILE" ] && [ -f "$SSH_PUBLIC_KEY_FILE" ]; then
    cp "$SSH_PUBLIC_KEY_FILE" /home/${USER_NAME}/.ssh/authorized_keys
    chown ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.ssh/authorized_keys
    chmod 600 /home/${USER_NAME}/.ssh/authorized_keys
    USE_KEY_AUTH=true
    echo "Loaded SSH public key from $SSH_PUBLIC_KEY_FILE"
elif [ -f "/home/${USER_NAME}/.ssh/authorized_keys" ]; then
    USE_KEY_AUTH=true
    echo "Using existing authorized_keys for $USER_NAME"
fi

# --- Password setup ---
if [ "$USE_KEY_AUTH" = "true" ]; then
    passwd -d "$USER_NAME" > /dev/null 2>&1
    DROPBEAR_FLAGS="$DROPBEAR_FLAGS -s -g"
    echo "Password authentication disabled (keys only)"
else
    if [ -n "$USER_PASS" ]; then
        echo "${USER_NAME}:${USER_PASS}" | chpasswd
        echo "Using provided password for $USER_NAME"
    else
        PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)
        echo "${USER_NAME}:${PASSWORD}" | chpasswd
        echo "=========================================="
        echo "SSH LOGIN CREDENTIALS:"
        echo "Username: $USER_NAME"
        echo "Password: $PASSWORD"
        echo "=========================================="
    fi
fi

# --- Start Dropbear ---
exec /usr/sbin/dropbear $DROPBEAR_FLAGS
