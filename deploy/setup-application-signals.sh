#!/bin/bash

# AWS Application Signals Setup Script for EC2
# This script configures Application Signals on each EC2 instance

echo "=== AWS Application Signals Setup ==="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as ec2-user, not root"
    exit 1
fi

# Function to install CloudWatch Agent
install_cloudwatch_agent() {
    echo "Installing CloudWatch Agent..."
    
    # Download CloudWatch Agent
    cd /tmp
    wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    
    # Install CloudWatch Agent
    sudo rpm -U ./amazon-cloudwatch-agent.rpm
    
    # Create CloudWatch Agent configuration for Application Signals
    sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "namespace": "AWS/ApplicationELB",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time",
                    "read_bytes",
                    "write_bytes",
                    "reads",
                    "writes"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    },
    "traces": {
        "traces_collected": {
            "xray": {
                "bind_address": "127.0.0.1:2000",
                "tcp_proxy_bind_address": "127.0.0.1:2000"
            },
            "otlp": {
                "grpc_endpoint": "127.0.0.1:4315",
                "http_endpoint": "127.0.0.1:4316"
            }
        }
    }
}
EOF

    # Start CloudWatch Agent
    sudo systemctl enable amazon-cloudwatch-agent
    sudo systemctl start amazon-cloudwatch-agent
    
    echo "CloudWatch Agent installed and started"
}

# Function to setup Application Signals for Backend
setup_backend_app_signals() {
    echo "Setting up Application Signals for Backend..."
    
    cd /opt/app
    
    # Install AWS OTEL Distro
    source venv/bin/activate
    pip install aws-opentelemetry-distro
    
    # Make scripts executable
    chmod +x deploy/backend/otel-env.sh
    chmod +x deploy/backend/start-with-otel.sh
    
    # Copy OTEL systemd service
    sudo cp deploy/backend/fastapi-otel.service /etc/systemd/system/
    
    # Stop existing service if running
    sudo systemctl stop fastapi-app.service 2>/dev/null || true
    sudo systemctl disable fastapi-app.service 2>/dev/null || true
    
    # Enable new OTEL service
    sudo systemctl daemon-reload
    sudo systemctl enable fastapi-otel.service
    
    echo "Backend Application Signals setup complete"
    echo "To start with OTEL: sudo systemctl start fastapi-otel.service"
}

# Function to setup Application Signals for Frontend
setup_frontend_app_signals() {
    echo "Setting up Application Signals for Frontend..."
    echo "Frontend doesn't require OTEL instrumentation"
    echo "Application Signals will monitor backend API calls from frontend"
}

# Function to setup Application Signals for Database
setup_database_app_signals() {
    echo "Setting up Application Signals for Database..."
    echo "Database metrics will be captured through backend connections"
    echo "No additional configuration needed for MySQL container"
}

# Main menu
echo "Select the type of EC2 instance:"
echo "1) Backend (FastAPI)"
echo "2) Frontend (Nginx)"
echo "3) Database (MySQL)"
echo "4) Install CloudWatch Agent only"
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        install_cloudwatch_agent
        setup_backend_app_signals
        ;;
    2)
        install_cloudwatch_agent
        setup_frontend_app_signals
        ;;
    3)
        install_cloudwatch_agent
        setup_database_app_signals
        ;;
    4)
        install_cloudwatch_agent
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=== Application Signals Setup Complete ==="
echo ""
echo "Next Steps:"
echo "1. Ensure EC2 instance has proper IAM role with CloudWatch permissions"
echo "2. For Backend: sudo systemctl start fastapi-otel.service"
echo "3. Check CloudWatch Agent: sudo systemctl status amazon-cloudwatch-agent"
echo "4. View Application Signals in AWS Console"