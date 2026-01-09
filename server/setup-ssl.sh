#!/bin/bash

# Script to wait for DNS propagation and setup SSL certificate
# Usage: ./setup-ssl.sh

DOMAIN="api.ra-alislam.sch.id"
SERVER_IP="159.223.44.203"
EMAIL="admin@ra-alislam.sch.id"

echo "Waiting for DNS propagation for $DOMAIN..."
echo "Expected IP: $SERVER_IP"
echo ""

# Check DNS resolution every 30 seconds
MAX_ATTEMPTS=40  # 20 minutes max
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo "Attempt $ATTEMPT/$MAX_ATTEMPTS - Checking DNS..."
    
    # Check with multiple DNS servers
    RESOLVED_IP=$(dig +short $DOMAIN @8.8.8.8 | grep -E '^[0-9.]+$' | head -1)
    
    if [ "$RESOLVED_IP" == "$SERVER_IP" ]; then
        echo "✓ DNS resolved correctly: $DOMAIN -> $RESOLVED_IP"
        echo ""
        echo "Requesting SSL certificate from Let's Encrypt..."
        
        # SSH to server and request certificate
        ssh root@$SERVER_IP "certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL --redirect"
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✓ SSL certificate installed successfully!"
            echo "✓ HTTPS is now enabled for $DOMAIN"
            echo ""
            echo "Update Flutter app to use: https://$DOMAIN"
            exit 0
        else
            echo "✗ Failed to obtain SSL certificate"
            echo "Check /var/log/letsencrypt/letsencrypt.log on the server"
            exit 1
        fi
    else
        if [ -z "$RESOLVED_IP" ]; then
            echo "  DNS not found yet (NXDOMAIN)"
        else
            echo "  DNS resolved to wrong IP: $RESOLVED_IP (expected: $SERVER_IP)"
        fi
        
        if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
            echo "  Waiting 30 seconds before retry..."
            sleep 30
        fi
    fi
done

echo ""
echo "✗ DNS propagation timeout after $((MAX_ATTEMPTS * 30 / 60)) minutes"
echo "Please check your DNS settings and try again later"
exit 1
