#!/bin/bash
set -e

# Create rndc.key from secret only if it doesn't exist
if [ -f /run/secrets/rndc_key ] && [ ! -f /etc/bind/rndc.key ]; then
    echo "Creating rndc.key from secret..."
    cat > /etc/bind/rndc.key <<EOF
key "rndc-key" {
    algorithm hmac-sha256;
    secret "$(cat /run/secrets/rndc_key)";
};
EOF
    chmod 640 /etc/bind/rndc.key
    chown root:bind /etc/bind/rndc.key
fi

# Call the original entrypoint with full path
exec /usr/local/bin/docker-entrypoint.sh "$@"