#!/bin/bash

# Start FastAPI application with AWS Application Signals instrumentation

# Change to application directory
cd /opt/app

# Activate virtual environment
source venv/bin/activate

# Load OpenTelemetry environment variables
source /opt/app/deploy/backend/otel-env.sh

# Start application with OpenTelemetry instrumentation
echo "Starting FastAPI application with AWS Application Signals..."
opentelemetry-instrument python main.py