#!/bin/bash

# Simple build script for the discovery_snapshot example

set -e

# Set default CONNEXTDDS_ARCH if not already set
if [ -z "$CONNEXTDDS_ARCH" ]; then
    export CONNEXTDDS_ARCH=x64Linux4gcc7.3.0
    echo "INFO: CONNEXTDDS_ARCH not set, using default: $CONNEXTDDS_ARCH"
fi

# Check environment variables and auto-detect NDDSHOME if not set
if [ -z "$NDDSHOME" ]; then
    # First try ~/rti_connext_dds-7.3.0, then /opt/rti.com/rti_connext_dds-7.3.0/
    if [ -d "$HOME/rti_connext_dds-7.3.0" ]; then
        export NDDSHOME="$HOME/rti_connext_dds-7.3.0"
    elif [ -d "/opt/rti.com/rti_connext_dds-7.3.0" ]; then
        export NDDSHOME="/opt/rti.com/rti_connext_dds-7.3.0"
    else
        echo "ERROR: NDDSHOME environment variable is not set and RTI Connext DDS installation not found"
        echo "Please install RTI Connext DDS to one of these locations:"
        echo "  ~/rti_connext_dds-7.3.0"
        echo "  /opt/rti.com/rti_connext_dds-7.3.0"
        echo ""
        echo "Or set NDDSHOME manually: export NDDSHOME=~/rti_connext_dds-7.3.0"
        exit 1
    fi
fi

echo "Building discovery_snapshot example..."
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
echo "  Terminal 1: ./build/discovery_snapshot_subscriber -d 0 -s 5"
echo "  Terminal 2: ./build/discovery_snapshot_publisher -d 0 -s 5"
echo ""

