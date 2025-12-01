#!/bin/bash

# Simple build script for the builtin_qos_profiles example

set -e

# Set default CONNEXTDDS_ARCH if not already set
if [ -z "$CONNEXTDDS_ARCH" ]; then
    export CONNEXTDDS_ARCH=x64Linux4gcc7.3.0
    echo "INFO: CONNEXTDDS_ARCH not set, using default: $CONNEXTDDS_ARCH"
fi

# Check environment variables
if [ -z "$NDDSHOME" ]; then
    echo "ERROR: NDDSHOME environment variable is not set"
    echo "Please set it to your RTI Connext DDS installation directory"
    echo "Example: export NDDSHOME=/home/robert/rti_connext_dds-7.3.0"
    exit 1
fi

echo "Building builtin_qos_profiles example..."
echo "NDDSHOME: $NDDSHOME"
echo "CONNEXTDDS_ARCH: $CONNEXTDDS_ARCH"
echo ""

# Create and enter build directory
mkdir -p build
cd build

# Run CMake
echo "Configuring with CMake..."
cmake ..

# Build
echo ""
echo "Building..."
cmake --build .

echo ""
echo "Build complete!"
echo ""
echo "To run the example:"
echo "  Terminal 1: ./build/subscriber -d 0 -s 10"
echo "  Terminal 2: ./build/publisher -d 0 -s 10"
echo ""
echo "Or run both automatically:"
echo "  ./run.sh"
