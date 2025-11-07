#!/bin/bash

# AL2023 Frontend Setup Script

echo "=== Frontend EC2 Setup Script ==="

# Update system
sudo dnf update -y

# Install nginx and git
sudo dnf install -y nginx git

# Create application directory
sudo mkdir -p /opt/frontend
sudo chown ec2-user:ec2-user /opt/frontend
cd /opt/frontend

# Clone repository
git clone https://github.com/Leeeuijooo/cloudwatch-application-signals.git .

# Configure nginx
sudo tee /etc/nginx/conf.d/frontend.conf > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    root /opt/frontend/static;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # API proxy to backend
    location /api/ {
        proxy_pass http://BACKEND_EC2_PRIVATE_IP:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Remove default nginx config
sudo rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true

# Enable and start nginx
sudo systemctl enable nginx
sudo systemctl start nginx

echo "Frontend setup complete!"
echo "Nginx status:"
sudo systemctl status nginx