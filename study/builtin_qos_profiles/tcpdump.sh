#!/bin/bash

# Script to capture DDS network traffic using tcpdump
# This is an alternative to the built-in network capture feature

CAPTURE_FILE="dds_capture_$(date +%Y%m%d_%H%M%S).pcap"

echo "Starting network capture..."
echo "Capture file: $CAPTURE_FILE"
echo ""
echo "Press Ctrl+C to stop capture"
echo ""

# Capture UDP traffic on common DDS ports
# Port 7400: Default domain 0 discovery
# Port 7401: Default domain 0 user data
sudo tcpdump -i any -w "$CAPTURE_FILE" \
    'udp port 7400 or udp port 7401 or udp portrange 7410-7420'

echo ""
echo "Capture stopped. File saved as: $CAPTURE_FILE"
echo "View with: wireshark $CAPTURE_FILE"
