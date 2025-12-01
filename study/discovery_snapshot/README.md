# Discovery Snapshot Example

A C++11 example demonstrating how to capture and save DDS discovery information using RTI Connext DDS Discovery Snapshot functionality.

## Overview

This example demonstrates:
- Capturing discovery information at runtime
- Saving discovery snapshots to XML files
- Analyzing DDS domain discovery state
- Debugging discovery issues

## Discovery Snapshot

Discovery Snapshot is a feature that allows you to capture the current state of DDS discovery at any point in time. This includes:
- **Participant Discovery**: All discovered DomainParticipants
- **Topic Discovery**: All discovered Topics
- **Endpoint Discovery**: All discovered DataWriters and DataReaders
- **QoS Information**: QoS settings for all discovered entities

The snapshot is saved as an XML file that can be analyzed to understand the discovery state, debug connectivity issues, or document the system configuration.

## Prerequisites

- RTI Connext DDS 7.3.0
- `NDDSHOME` environment variable set (or auto-detected by build.sh)
- CMake 3.11 or later
- C++ compiler with C++11 support
- Linux x64 system (or adjust `CONNEXTDDS_ARCH`)

## Quick Start

```bash
# 1. Build
./build.sh

# 2. Run in separate terminals
./build/discovery_snapshot_subscriber -d 0 -s 5    # Terminal 1
./build/discovery_snapshot_publisher -d 0 -s 5     # Terminal 2
```

After running, discovery snapshot files will be generated in the current directory.

## Building

### Automated Build

```bash
./build.sh
```

The build script will:
- Auto-detect `NDDSHOME` if not set
- Set default `CONNEXTDDS_ARCH` if not set
- Create build directory
- Configure and build with CMake

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
- `-s <count>` - Number of samples to send/receive (default: 5)
- `-h` - Display help

### Example Output

**Publisher:**
```
Writing DiscoverySnapshot, count 0
Writing DiscoverySnapshot, count 1
Writing DiscoverySnapshot, count 2
...
```

**Subscriber:**
```
DiscoverySnapshot subscriber sleeping up to 1 sec...
DiscoverySnapshot(0)
DiscoverySnapshot subscriber sleeping up to 1 sec...
DiscoverySnapshot(1)
...
```

### Discovery Snapshot Files

After running the applications, you will find discovery snapshot files in the current directory:

- `*_participant_snapshot.xml` - Participant-level discovery information
- `*_datawriter_snapshot.xml` - DataWriter-level discovery information
- `*_datareader_snapshot.xml` - DataReader-level discovery information

The files are named with a timestamp and GUID to ensure uniqueness.

## Project Structure

```
discovery_snapshot/
├── discovery_snapshot.idl              # IDL data type definition
├── discovery_snapshot_publisher.cxx     # Publisher application
├── discovery_snapshot_subscriber.cxx    # Subscriber application
├── application.hpp                     # Argument parsing and signal handling
├── USER_QOS_PROFILES.xml               # QoS configuration
├── CMakeLists.txt                      # CMake build configuration
├── build.sh                            # Build script
├── README.md                           # This file
└── .gitignore                          # Git ignore patterns
```

## Key Concepts

### Discovery Snapshot API

The example uses the `rti::util::discovery::take_snapshot()` function:

```cpp
// Take snapshot at participant level
rti::util::discovery::take_snapshot(participant);

// Take snapshot at endpoint level
rti::util::discovery::take_snapshot(writer);
rti::util::discovery::take_snapshot(reader);
```

### When to Take Snapshots

Snapshots can be taken at any point:
- **After discovery completes**: Wait for participants to discover each other
- **During data exchange**: Capture discovery state while data is flowing
- **On errors**: Capture discovery state when issues occur
- **Periodically**: Monitor discovery changes over time

### Snapshot File Contents

The XML snapshot files contain:
- **GUIDs**: Globally Unique Identifiers for all entities
- **QoS Settings**: Complete QoS configuration for each entity
- **Matching Information**: Which endpoints are matched
- **Transport Information**: Transport details and addresses
- **Discovery Status**: Current discovery state

## Use Cases

### Debugging Discovery Issues

1. Run applications with discovery snapshots
2. Analyze snapshot files to see what was discovered
3. Compare snapshots from different times
4. Identify missing endpoints or QoS mismatches

### System Documentation

1. Capture discovery state after system initialization
2. Document network topology
3. Verify QoS configurations
4. Create system configuration reports

### Monitoring

1. Take periodic snapshots
2. Track discovery changes over time
3. Monitor endpoint lifecycle
4. Analyze discovery performance

## Troubleshooting

**Error: "NDDSHOME not found"**
```bash
export NDDSHOME=/path/to/rti_connext_dds-7.3.0
# Or let build.sh auto-detect it
```

**Error: "CONNEXTDDS_ARCH not found"**
```bash
export CONNEXTDDS_ARCH=x64Linux4gcc7.3.0
# Or let build.sh use default
```

**No snapshot files generated**
- Ensure applications run long enough for discovery to complete
- Check file permissions in the current directory
- Verify the snapshot API is called (check application code)

**Empty or incomplete snapshots**
- Wait longer for discovery to complete
- Ensure both publisher and subscriber are running
- Check network connectivity
- Verify domain IDs match

**Build errors**
- Verify CMake 3.11+
- Check `rtiddsgen` is in PATH
- Ensure correct NDDSHOME and CONNEXTDDS_ARCH
- Run `git submodule update --init` if CMake utils are missing

## Cleaning Up

```bash
# Clean build artifacts
rm -rf build/

# Clean snapshot files
rm -f *_snapshot.xml

# Clean log files
rm -f *.log
```

## Additional Resources

- [RTI Connext DDS Documentation](https://community.rti.com/documentation)
- [Discovery Snapshot API Reference](https://community.rti.com/static/documentation/connext-dds/7.3.0/doc/api/connext_dds/api_cpp2/group__DDSDiscoverySnapshotModule.html)
- [RTI Community Portal](https://community.rti.com)
