#!/bin/bash

# Quick deployment script for EC2 MSA setup
# Usage: ./quick-deploy.sh <backend-ip> <frontend-ip> <database-ip>

if [ $# -ne 3 ]; then
    echo "Usage: $0 <backend-private-ip> <frontend-public-ip> <database-private-ip>"
    echo "Example: $0 172.31.1.10 54.123.45.67 172.31.1.20"
    exit 1
fi

BACKEND_IP=$1
FRONTEND_IP=$2
DATABASE_IP=$3

echo "=== EC2 MSA Deployment Script ==="
echo "Backend Private IP: $BACKEND_IP"
echo "Frontend Public IP: $FRONTEND_IP"
echo "Database Private IP: $DATABASE_IP"
echo ""

# Update frontend nginx config template
sed -i "s/BACKEND_EC2_PRIVATE_IP/$BACKEND_IP/g" deploy/frontend/setup.sh

# Create backend environment file
cat > deploy/backend/.env <<EOF
DB_HOST=$DATABASE_IP
DB_PORT=3306
DB_USER=testuser
DB_PASSWORD=testpass
DB_NAME=testdb

API_HOST=0.0.0.0
API_PORT=8000
EOF

echo "Configuration files updated!"
echo ""
echo "Next steps:"
echo "1. Deploy Database EC2:"
echo "   ssh ec2-user@$DATABASE_IP 'curl -o setup.sh https://raw.githubusercontent.com/Leeeuijooo/cloudwatch-application-signals/main/deploy/database/setup.sh && chmod +x setup.sh && ./setup.sh'"
echo ""
echo "2. Deploy Backend EC2:"
echo "   ssh ec2-user@$BACKEND_IP 'curl -o setup.sh https://raw.githubusercontent.com/Leeeuijooo/cloudwatch-application-signals/main/deploy/backend/setup.sh && chmod +x setup.sh && ./setup.sh'"
echo ""
echo "3. Deploy Frontend EC2:"
echo "   ssh ec2-user@$FRONTEND_IP 'curl -o setup.sh https://raw.githubusercontent.com/Leeeuijooo/cloudwatch-application-signals/main/deploy/frontend/setup.sh && chmod +x setup.sh && ./setup.sh'"
echo ""
echo "4. Access application at: http://$FRONTEND_IP"