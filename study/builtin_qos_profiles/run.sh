#!/bin/bash

# Quick run script - starts both publisher and subscriber

# Source environment if needed
if [ -z "$NDDSHOME" ]; then
    echo "Setting up RTI Connext DDS environment..."
    source ./setup_env.sh
fi

# Check if build exists
if [ ! -d "build" ]; then
    echo "Build directory not found. Building first..."
    ./build.sh
fi

# Check if executables exist
if [ ! -f "./build/publisher" ] || [ ! -f "./build/subscriber" ]; then
    echo "Error: Executables not found. Please run ./build.sh first"
    exit 1
fi

echo "Starting subscriber in background..."
./build/subscriber -d 0 -s 20 &
SUBSCRIBER_PID=$!

# Give subscriber time to start
sleep 2

echo "Starting publisher..."
./build/publisher -d 0 -s 20

# Wait for subscriber to finish
wait $SUBSCRIBER_PID

echo ""
echo "Example finished!"
