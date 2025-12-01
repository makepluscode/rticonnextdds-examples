#!/bin/bash

# Environment setup script for RTI Connext DDS
# Source this file before building: source setup_env.sh

# Set NDDSHOME to your RTI Connext DDS installation
# First try ~/rti_connext_dds-7.3.0, then /opt/rti.com/rti_connext_dds-7.3.0/
if [ -d "$HOME/rti_connext_dds-7.3.0" ]; then
    export NDDSHOME="$HOME/rti_connext_dds-7.3.0"
elif [ -d "/opt/rti.com/rti_connext_dds-7.3.0" ]; then
    export NDDSHOME="/opt/rti.com/rti_connext_dds-7.3.0"
else
    echo "ERROR: RTI Connext DDS installation not found"
    echo "Please install RTI Connext DDS to one of these locations:"
    echo "  ~/rti_connext_dds-7.3.0"
    echo "  /opt/rti.com/rti_connext_dds-7.3.0"
    echo ""
    echo "Or set NDDSHOME manually before sourcing this script"
    exit 1
fi

# Detect architecture automatically
if [ -z "$CONNEXTDDS_ARCH" ]; then
    # Try to find a Linux architecture in the lib directory
    if [ -d "$NDDSHOME/lib" ]; then
        ARCH=$(ls "$NDDSHOME/lib" | grep -E '^x64Linux' | head -1)
        if [ -n "$ARCH" ]; then
            export CONNEXTDDS_ARCH="$ARCH"
        else
            # Default fallback
            export CONNEXTDDS_ARCH="x64Linux4gcc7.3.0"
            echo "Warning: Could not auto-detect architecture. Using default: $CONNEXTDDS_ARCH"
        fi
    fi
fi

# Add rtiddsgen to PATH
export PATH="$NDDSHOME/bin:$PATH"

# Add Connext libraries to LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$NDDSHOME/lib/$CONNEXTDDS_ARCH:$LD_LIBRARY_PATH"

echo "RTI Connext DDS Environment Setup"
echo "=================================="
echo "NDDSHOME: $NDDSHOME"
echo "CONNEXTDDS_ARCH: $CONNEXTDDS_ARCH"
echo "PATH updated to include: $NDDSHOME/bin"
echo "LD_LIBRARY_PATH updated"
echo ""
echo "Ready to build! Run: ./build.sh"
echo ""
echo "To run after building:"
echo "  Terminal 1: ./build/subscriber -d 0 -s 10"
echo "  Terminal 2: ./build/publisher -d 0 -s 10"
