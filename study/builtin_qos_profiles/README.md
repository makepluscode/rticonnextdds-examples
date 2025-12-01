# Built-in QoS Profiles Example

A simple C++98 example demonstrating how to use RTI Connext DDS built-in QoS profiles.

## Overview

This example demonstrates:
- Using built-in QoS profiles from `BuiltinQosLibExp` and `BuiltinQosLib`
- Configuring DDS entities via XML QoS profiles
- Basic publisher-subscriber pattern with reliable streaming
- Enabling monitoring on DomainParticipant

## Built-in QoS Profiles Used

1. **BuiltinQosLibExp::Pattern.ReliableStreaming** - Reliable, ordered data delivery for streaming
2. **BuiltinQosLib::Generic.Monitoring.Common** - Enables monitoring on DomainParticipant

## Prerequisites

- RTI Connext DDS 7.3.0
- `NDDSHOME` environment variable set
- CMake 3.11 or later
- C++ compiler with C++98 support
- Linux x64 system (or adjust `CONNEXTDDS_ARCH`)

## Quick Start

```bash
# 1. Setup environment
source setup.sh

# 2. Build
./build.sh

# 3. Run in separate terminals
./build/subscriber -d 0 -s 10    # Terminal 1
./build/publisher -d 0 -s 10     # Terminal 2

# Or run both automatically
./run.sh
```

## Building

### Automated Build

```bash
./build.sh
```

### Manual Build

```bash
# Set environment
export NDDSHOME=/path/to/rti_connext_dds-7.3.0
export CONNEXTDDS_ARCH=x64Linux4gcc7.3.0
export PATH="$NDDSHOME/bin:$PATH"
export LD_LIBRARY_PATH="$NDDSHOME/lib/$CONNEXTDDS_ARCH:$LD_LIBRARY_PATH"

# Build
mkdir -p build && cd build
cmake ..
cmake --build .
```

## Running

### Command-line Options

Both applications accept:
- `-d <domain_id>` - DDS domain ID (default: 0)
- `-s <count>` - Number of samples (default: unlimited)
- `-h` - Display help

### Example Output

**Subscriber:**
```
Subscriber started. Waiting for samples...
Received Message: id=0, content="Hello World! Count: 0"
Received Message: id=1, content="Hello World! Count: 1"
...
```

**Publisher:**
```
Publisher started. Writing samples...
Writing Message: id=0, content="Hello World! Count: 0"
Writing Message: id=1, content="Hello World! Count: 1"
...
```

## Project Structure

```
builtin_qos_profiles/
├── message.idl              # IDL data type definition
├── publisher.cxx            # Publisher application
├── subscriber.cxx           # Subscriber application
├── application.h            # Argument parsing and signal handling
├── USER_QOS_PROFILES.xml    # QoS configuration
├── CMakeLists.txt           # CMake build configuration
├── setup.sh                # Environment setup script
├── build.sh                # Build script
├── run.sh                  # Auto-run both apps
├── tcpdump.sh              # Network capture helper
├── README.md               # This file
├── QUICKSTART.md           # Quick reference
└── .gitignore              # Git ignore patterns
```

## Key Concepts

### Built-in QoS Profiles

RTI Connext provides pre-configured QoS profiles:
- **Pattern profiles**: ReliableStreaming, Event, Status, AlarmEvent, etc.
- **Generic profiles**: StrictReliable, BestEffort, KeepLastReliable, etc.
- **Monitoring profiles**: Enable built-in monitoring capabilities
- **Compatibility profiles**: For interoperability with other systems

### XML QoS Configuration

The `USER_QOS_PROFILES.xml` inherits from built-in profiles:

```xml
<qos_profile name="DefaultProfile"
             base_name="BuiltinQosLibExp::Pattern.ReliableStreaming">
```

This provides reliable, ordered delivery without manually configuring individual QoS policies.

### Dynamic Linking Requirement

This example requires dynamic linking because monitoring functionality is loaded at runtime. The CMakeLists.txt automatically sets `BUILD_SHARED_LIBS=ON`.

## Network Capture (PCAP)

Capture DDS network traffic for analysis:

### Using tcpdump

```bash
# In one terminal, start capture
sudo ./tcpdump.sh

# In other terminals, run applications
./build/subscriber -d 0 -s 10 &
./build/publisher -d 0 -s 10

# Stop capture with Ctrl+C
# View with Wireshark
wireshark dds_capture_*.pcap
```

### Manual Capture

```bash
# Capture UDP traffic on DDS ports
sudo tcpdump -i any -w capture.pcap 'udp port 7400 or udp port 7401'
```

### Analyzing with Wireshark

- Wireshark has built-in RTPS (DDS protocol) decoder
- Filter by `rtps` to see only DDS traffic
- Inspect discovery packets, data samples, acknowledgments
- View reliability protocol behavior

## Troubleshooting

**Error: "NDDSHOME not found"**
```bash
export NDDSHOME=/path/to/rti_connext_dds-7.3.0
```

**Error: "CONNEXTDDS_ARCH not found"**
```bash
export CONNEXTDDS_ARCH=x64Linux4gcc7.3.0
```

**No data received**
- Ensure both apps use same domain ID
- Check `USER_QOS_PROFILES.xml` is in working directory
- Verify firewall allows UDP multicast
- Check applications are running on same network

**Build errors**
- Verify CMake 3.11+
- Check `rtiddsgen` is in PATH
- Ensure correct NDDSHOME and CONNEXTDDS_ARCH

## Cleaning Up

```bash
# Clean build artifacts
rm -rf build/

# Clean PCAP files
rm -f *.pcap

# Clean log files
rm -f *.log
```

## Additional Resources

- [RTI Connext DDS Documentation](https://community.rti.com/documentation)
- [Built-in QoS Profiles Reference](https://community.rti.com/static/documentation/connext-dds/7.3.0/doc/manuals/connext_dds_professional/users_manual/users_manual/BuiltinQosProfiles.htm)
- [RTI Community Portal](https://community.rti.com)
