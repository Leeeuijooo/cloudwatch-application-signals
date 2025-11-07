#!/bin/bash

# AL2023 Backend Setup Script

echo "=== Backend EC2 Setup Script ==="

# Update system
sudo dnf update -y

# Install Python 3.11 and pip
sudo dnf install -y python3.11 python3.11-pip git

# Install development tools
sudo dnf groupinstall -y "Development Tools"

# Create application directory
sudo mkdir -p /opt/app
sudo chown ec2-user:ec2-user /opt/app
cd /opt/app

# Clone repository
git clone https://github.com/Leeeuijooo/cloudwatch-application-signals.git .

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create systemd service
sudo tee /etc/systemd/system/fastapi-app.service > /dev/null <<EOF
[Unit]
Description=FastAPI Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app
Environment=PATH=/opt/app/venv/bin
ExecStart=/opt/app/venv/bin/python main.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable fastapi-app
sudo systemctl start fastapi-app

echo "Backend setup complete!"
echo "Service status:"
sudo systemctl status fastapi-app