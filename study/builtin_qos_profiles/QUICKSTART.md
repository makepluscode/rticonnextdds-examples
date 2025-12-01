# Quick Start Guide

## One-Command Run

```bash
./run.sh
```

## Step-by-Step

### 1. Setup Environment

```bash
source setup.sh
```

### 2. Build

```bash
./build.sh
```

### 3. Run

**Separate terminals (recommended):**

Terminal 1:
```bash
./build/subscriber -d 0 -s 10
```

Terminal 2:
```bash
./build/publisher -d 0 -s 10
```

## Expected Output

**Subscriber:**
```
Subscriber started. Waiting for samples...
Received Message: id=0, content="Hello World! Count: 0"
Received Message: id=1, content="Hello World! Count: 1"
Received Message: id=2, content="Hello World! Count: 2"
...
```

**Publisher:**
```
Publisher started. Writing samples...
Writing Message: id=0, content="Hello World! Count: 0"
Writing Message: id=1, content="Hello World! Count: 1"
Writing Message: id=2, content="Hello World! Count: 2"
...
```

## Command-Line Options

- `-d <domain_id>` - Domain ID (default: 0)
- `-s <count>` - Number of samples (default: unlimited)
- `-h` - Show help

## Network Capture

Capture DDS traffic for analysis:

```bash
# Start capture
sudo ./tcpdump.sh

# Run applications (in other terminals)
./build/subscriber -d 0 -s 10 &
./build/publisher -d 0 -s 10

# Stop capture with Ctrl+C
# View with Wireshark
wireshark dds_capture_*.pcap
```

## Troubleshooting

**NDDSHOME not set:**
```bash
export NDDSHOME=/home/robert/rti_connext_dds-7.3.0
```

**No data received:**
- Start subscriber before publisher
- Check both use same domain ID (-d option)
- Verify firewall settings

## Cleaning Up

```bash
rm -rf build/     # Remove build files
rm -f *.pcap      # Remove capture files
rm -f *.log       # Remove log files
```
