#!/bin/bash

# AWS Application Signals OpenTelemetry Environment Variables
# Source this file before starting your application

export OTEL_METRICS_EXPORTER=none
export OTEL_LOGS_EXPORTER=none
export OTEL_AWS_APPLICATION_SIGNALS_ENABLED=true
export OTEL_PYTHON_DISTRO=aws_distro
export OTEL_PYTHON_CONFIGURATOR=aws_configurator
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_TRACES_SAMPLER=xray
export OTEL_TRACES_SAMPLER_ARG="endpoint=http://localhost:2000"
export OTEL_AWS_APPLICATION_SIGNALS_EXPORTER_ENDPOINT=http://localhost:4316/v1/metrics
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://localhost:4316/v1/traces

# Service configuration - update these values
export SERVICE_NAME="fastapi-backend"
export DEPLOYMENT_ENVIRONMENT="production"
export LOG_GROUP_NAME="/aws/ec2/fastapi-backend"

# Combine resource attributes
export OTEL_RESOURCE_ATTRIBUTES="service.name=${SERVICE_NAME},deployment.environment=${DEPLOYMENT_ENVIRONMENT},aws.log.group.names=${LOG_GROUP_NAME}"

# Python path configuration (required for some containerized applications)
export PYTHONPATH="/opt/app:${PYTHONPATH}"

echo "OpenTelemetry environment configured for AWS Application Signals"
echo "Service Name: ${SERVICE_NAME}"
echo "Environment: ${DEPLOYMENT_ENVIRONMENT}"
echo "Log Group: ${LOG_GROUP_NAME}"