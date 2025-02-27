#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if hey is installed
if ! command -v hey &> /dev/null; then
    echo -e "${RED}Error: 'hey' is not installed${NC}"
    echo "Installing hey..."
    export PATH=$PATH:$(go env GOPATH)/bin
    go install github.com/rakyll/hey@latest
    if ! command -v hey &> /dev/null; then
        echo -e "${RED}Failed to install hey. Please install it manually:${NC}"
        echo "go install github.com/rakyll/hey@latest"
        echo "And make sure your GOPATH/bin is in your PATH"
        exit 1
    fi
fi

# Configuration
PROXY_URL=${PROXY_URL:-"http://localhost:8000/mock"}
CONCURRENT_USERS=50
DURATION="30s"

echo -e "${BLUE}TrustGate Benchmark Tool${NC}\n"

# Test 1: System endpoint (ping)
echo -e "${GREEN}Testing system ping endpoint...${NC}"
echo -e "\n${BLUE}Starting system benchmark with ${CONCURRENT_USERS} concurrent users for ${DURATION}...${NC}"
hey -z ${DURATION} \
    -c ${CONCURRENT_USERS} \
    -disable-keepalive \
    -cpus 2 \
    "${PROXY_URL}"
