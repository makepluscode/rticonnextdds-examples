# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains examples demonstrating RTI Connext DDS features. The examples are built and tested against RTI Connext DDS 7.3.0. Examples are organized by feature category and support multiple programming languages (C, C++98, C++11, Java, Python, C#).

## Repository Structure

```
examples/
├── connext_dds/           # Core Connext DDS feature examples
├── cloud_discovery_service/
├── routing_service/
├── recording_service/
├── persistence_service/
├── connext_secure/        # Security-related examples
└── web_integration_service/

resources/
├── cmake/                 # Shared CMake utilities and modules
├── gradle_plugin/         # Gradle build utilities for Java examples
├── security/             # Security certificates and configurations
└── markdown_templates/   # Documentation templates
```

### Example Organization

Each example follows this structure:
```
example_name/
├── README.md             # Feature overview and concept explanation
├── c/                    # C implementation
├── c++98/               # C++98 implementation
├── c++11/               # C++11 implementation (modern C++)
├── java/                # Java implementation
├── py/                  # Python implementation
├── cs/                  # C# implementation
```

Within each language directory:
- `*.idl` - IDL type definition files
- `*_publisher.*` - Publisher application
- `*_subscriber.*` - Subscriber application
- `CMakeLists.txt` - CMake build configuration (C/C++)
- `build.gradle` - Gradle build configuration (Java)
- `*.csproj` - MSBuild project file (C#)
- `USER_QOS_PROFILES.xml` - QoS configuration (if needed)
- `README.md` - Language-specific build and run instructions

## Build System

### Prerequisites

- RTI Connext DDS installation with `NDDSHOME` environment variable set
- For CMake builds: `CONNEXTDDS_ARCH` environment variable set to target architecture
- For Gradle builds: `CONNEXTDDS_ARCH` environment variable set

### Building C/C++ Examples

Individual example build:
```bash
cd examples/connext_dds/<example_name>/<c|c++98|c++11>
mkdir build && cd build
cmake ..
cmake --build .
```

For multi-config generators (Visual Studio):
```bash
cmake --build . --config Release
# or
cmake --build . --config Debug
```

Build all Connext DDS examples from top level:
```bash
cd examples
mkdir build && cd build
cmake ..
cmake --build .
```

Build with optional service examples:
```bash
cmake .. -DCONNEXTDDS_BUILD_ROUTING_SERVICE_EXAMPLES=ON
cmake .. -DCONNEXTDDS_BUILD_RECORDING_SERVICE_EXAMPLES=ON
cmake .. -DCONNEXTDDS_BUILD_PERSISTENCE_SERVICE_EXAMPLES=ON
cmake .. -DCONNEXTDDS_BUILD_CLOUD_DISCOVERY_SERVICE_EXAMPLES=ON
cmake .. -DCONNEXTDDS_BUILD_CONNEXT_SECURE_EXAMPLES=ON
```

### Building Java Examples

Individual example build:
```bash
cd examples/connext_dds/<example_name>/java
gradle build
```

Build all Java examples:
```bash
cd examples/connext_dds
gradle build
```

### Building C# Examples

C# examples use MSBuild via .csproj files:
```bash
cd examples/connext_dds/<example_name>/cs
dotnet build
# or
msbuild <ProjectName>.csproj
```

### Python Examples

Python examples typically don't require building. They use the Connext Python API directly:
```bash
cd examples/connext_dds/<example_name>/py
python3 <script_name>.py
```

## Running Examples

Most examples follow a publisher/subscriber pattern. Run in separate terminals:

**C/C++ (Unix):**
```bash
./<example>_publisher -d <domain_id> -s <sample_count>
./<example>_subscriber -d <domain_id> -s <sample_count>
```

**C/C++ (Windows):**
```bash
<example>_publisher.exe -d <domain_id> -s <sample_count>
<example>_subscriber.exe -d <domain_id> -s <sample_count>
```

**Java:**
```bash
gradle run -PmainClass=<PublisherClassName> -Pargs="<args>"
# or after building JAR
java -cp build/libs/*.jar <PublisherClassName> <args>
```

**Python:**
```bash
python3 <example>_publisher.py
python3 <example>_subscriber.py
```

Common arguments:
- `-d <domain_id>` - DDS domain ID (default: 0)
- `-s <sample_count>` - Number of samples to send/receive (default: infinite)

**Important:** Run examples from their directory to ensure they load the correct `USER_QOS_PROFILES.xml` file.

## CMake Build Infrastructure

The repository uses custom CMake modules in `resources/cmake/Modules/`:

- `ConnextDdsConfigureCmakeUtils.cmake` - Configures CMake environment, finds RTI Connext DDS
- `ConnextDdsAddExamplesSubdirectories.cmake` - Recursively adds example subdirectories
- `ConnextDdsBuildAllConfigurations.cmake` - Handles multi-configuration builds
- `ConnextDdsGenerateSecurityArtifacts.cmake` - Generates security certificates

Each example's CMakeLists.txt typically includes these modules and uses helper functions to configure IDL code generation, linking, and installation.

## Key Connext DDS Concepts

Examples demonstrate these core concepts:

- **Publishers/Subscribers** - Basic data distribution pattern
- **DataWriters/DataReaders** - Entities that write/read typed data
- **Topics** - Named data channels identified by type
- **QoS (Quality of Service)** - Configuration for reliability, durability, history, etc.
- **IDL (Interface Definition Language)** - Type definitions
- **DomainParticipants** - Entry point to DDS domain
- **Content Filtering** - Subscriber-side data filtering
- **Flow Controllers** - Throttling and batching mechanisms
- **Listeners/WaitSets** - Asynchronous and synchronous event handling
- **Dynamic Data** - Runtime type inspection and manipulation

## Static Analysis

From `examples/connext_dds/`, run:
```bash
mkdir build && cd build
cmake .. -DSTATIC_ANALYSIS=ON
cmake --build . --target static_analysis
```

This runs cppcheck on C/C++ code.

## Contributing

- Sign the Contributor License Agreement (CLA) at http://community.rti.com/cla
- Follow existing code structure and style
- Each example should have a README explaining the concept
- Support multiple languages where applicable
- Include USER_QOS_PROFILES.xml when QoS configuration is relevant

## Version Compatibility

This repository's master branch targets RTI Connext DDS 7.3.0. For older versions, check out the corresponding release branch (e.g., release/7.2.0, release/7.1.0, etc.).

## Important Notes

- All examples require RTI Connext DDS to be installed and NDDSHOME environment variable set
- CMake-based builds require CONNEXTDDS_ARCH to be set to your target architecture
- The repository uses git submodules - clone with `--recurse-submodule` or run `git submodule update --init --recursive`
