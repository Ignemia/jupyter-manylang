#!/bin/bash
# Build script for JupyterLab Multi-Language Docker Environment

set -e  # Exit on error

echo "==================================================================="
echo "Building JupyterLab Multi-Language Docker Environment"
echo "==================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[BUILD]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "Dockerfile.composite" ] || [ ! -d "kernels" ]; then
    print_error "This script must be run from the jupyter directory"
    exit 1
fi

# Build the composite image with all kernels
print_status "Building composite JupyterLab image with all language kernels..."
print_status "This may take a while as it builds all language environments..."

if docker build -f Dockerfile.composite -t jupyter-multilang:latest .; then
    print_status "Successfully built composite image"
else
    print_error "Failed to build composite image"
    exit 1
fi

# Tag the image for docker-compose
docker tag jupyter-multilang:latest jupyter-langs:latest

print_status "Build complete!"
print_status "Image tagged as: jupyter-multilang:latest and jupyter-langs:latest"

# Show image size
echo ""
print_status "Image information:"
docker images | grep -E "(jupyter-multilang|jupyter-langs)" | head -2

echo ""
print_status "To run the container:"
echo "  docker compose up -d"
echo ""
print_status "To check available kernels:"
echo "  docker exec jupyter-multilang jupyter kernelspec list"
echo ""
print_status "Access JupyterLab at: http://localhost:7654"
