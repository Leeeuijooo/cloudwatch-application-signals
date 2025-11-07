#!/bin/bash

# AL2023 Database Setup Script

echo "=== Database EC2 Setup Script ==="

# Update system
sudo dnf update -y

# Install Docker
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create application directory
sudo mkdir -p /opt/database
sudo chown ec2-user:ec2-user /opt/database
cd /opt/database

# Create Docker Compose file for MySQL
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mysql_server
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: testdb
      MYSQL_USER: testuser
      MYSQL_PASSWORD: testpass
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

volumes:
  mysql_data:
EOF

# Create init SQL file
cat > init.sql <<EOF
-- Initialize database
USE testdb;

-- Sample data can be added here if needed
-- INSERT INTO users (name, email, created_at) VALUES 
-- ('John Doe', 'john@example.com', NOW()),
-- ('Jane Smith', 'jane@example.com', NOW());
EOF

# Start MySQL service
echo "Starting MySQL service..."
docker-compose up -d

echo "Database setup complete!"
echo "MySQL status:"
docker-compose ps

echo "Waiting for MySQL to be ready..."
sleep 30
docker-compose exec mysql mysqladmin ping -h localhost --silent

echo "MySQL is ready!"
echo "Connection test:"
docker-compose exec mysql mysql -u testuser -ptestpass -e "SELECT 'Connection successful' as status;"