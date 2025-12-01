#!/bin/bash

# Quick run script - starts both publisher and subscriber
# and shows the generated discovery snapshot files

set -e

# Default parameters
DOMAIN_ID=${1:-0}
SAMPLE_COUNT=${2:-5}

# Check if build exists
if [ ! -d "build" ]; then
    echo "Build directory not found. Building first..."
    ./build.sh
fi

# Check if executables exist
if [ ! -f "./build/discovery_snapshot_publisher" ] || [ ! -f "./build/discovery_snapshot_subscriber" ]; then
    echo "Error: Executables not found. Please run ./build.sh first"
    exit 1
fi

# Clean up old snapshot files
echo "Cleaning up old snapshot files..."
rm -f *_snapshot.xml

echo ""
echo "=========================================="
echo "Running Discovery Snapshot Example"
echo "=========================================="
echo "Domain ID: $DOMAIN_ID"
echo "Sample Count: $SAMPLE_COUNT"
echo ""

# Start subscriber in background
echo "Starting subscriber in background..."
./build/discovery_snapshot_subscriber -d $DOMAIN_ID -s $SAMPLE_COUNT > subscriber.log 2>&1 &
SUBSCRIBER_PID=$!

# Give subscriber time to start and discover
echo "Waiting for subscriber to start..."
sleep 3

# Start publisher (runs in foreground)
echo "Starting publisher..."
./build/discovery_snapshot_publisher -d $DOMAIN_ID -s $SAMPLE_COUNT > publisher.log 2>&1

# Wait a bit for snapshots to be written
sleep 2

# Wait for subscriber to finish
echo "Waiting for subscriber to finish..."
wait $SUBSCRIBER_PID 2>/dev/null || true

# Wait a bit more for all snapshots to be written
sleep 1

echo ""
echo "=========================================="
echo "Example finished!"
echo "=========================================="
echo ""

# Check for generated snapshot files
echo "Looking for discovery snapshot files..."
SNAPSHOT_FILES=$(find . -maxdepth 1 -name "*_snapshot.xml" -type f 2>/dev/null | sort)

if [ -z "$SNAPSHOT_FILES" ]; then
    echo "WARNING: No snapshot files found!"
    echo "Check the logs for errors:"
    echo "  - publisher.log"
    echo "  - subscriber.log"
else
    echo ""
    echo "Generated snapshot files:"
    echo "------------------------"
    for file in $SNAPSHOT_FILES; do
        size=$(ls -lh "$file" | awk '{print $5}')
        echo "  $file ($size)"
    done
    echo ""
    echo "You can view the snapshot files with:"
    echo "  cat publisher_participant_snapshot.xml"
    echo "  cat publisher_datawriter_snapshot.xml"
    echo "  cat subscriber_participant_snapshot.xml"
    echo "  cat subscriber_datareader_snapshot.xml"
fi

echo ""
echo "Log files:"
echo "  - publisher.log"
echo "  - subscriber.log"
echo ""

