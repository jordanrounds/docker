#!/bin/bash
set -e

# Create tsig.key from secret if it exists
if [ -f /run/secrets/tsig_key ]; then
    echo "Creating tsig.key from secret..."
    cat > /etc/bind/tsig.key <<EOF
key "tsig-key" {
    algorithm hmac-sha256;
    secret "$(cat /run/secrets/tsig_key)";
};
EOF
    chmod 640 /etc/bind/tsig.key
    chown root:bind /etc/bind/tsig.key
fi

# Call the original entrypoint
exec docker-entrypoint.sh "$@"
