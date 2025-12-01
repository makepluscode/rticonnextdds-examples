cmake_minimum_required(VERSION 3.11)
project(builtin_qos_profiles_example)

# Set C++ standard
set(CMAKE_CXX_STANDARD 98)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# This example requires dynamic linking for monitoring
set(BUILD_SHARED_LIBS ON)

# Find RTI Connext DDS
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "$ENV{NDDSHOME}/resource/cmake")
find_package(RTIConnextDDS "7.3.0" REQUIRED COMPONENTS core)

# Add platform-specific defines
add_definitions(
    -DRTI_UNIX
    -DRTI_LINUX
    -DRTI_64BIT
)

# Define CONNEXTDDS_DIR for easier access
set(CONNEXTDDS_DIR "$ENV{NDDSHOME}")
set(CONNEXTDDS_ARCH "$ENV{CONNEXTDDS_ARCH}")

# Set up include directories
include_directories(
    "${CONNEXTDDS_DIR}/include"
    "${CONNEXTDDS_DIR}/include/ndds"
    "${CONNEXTDDS_DIR}/include/ndds/hpp"
)

# Set up library directories
link_directories(
    "${CONNEXTDDS_DIR}/lib/${CONNEXTDDS_ARCH}"
)

# Generate type support code from IDL
set(IDL_FILE "${CMAKE_CURRENT_SOURCE_DIR}/message.idl")
set(IDL_GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY ${IDL_GEN_DIR})

# Run rtiddsgen to generate C++ code
add_custom_command(
    OUTPUT
        ${IDL_GEN_DIR}/message.h
        ${IDL_GEN_DIR}/message.cxx
        ${IDL_GEN_DIR}/messagePlugin.h
        ${IDL_GEN_DIR}/messagePlugin.cxx
        ${IDL_GEN_DIR}/messageSupport.h
        ${IDL_GEN_DIR}/messageSupport.cxx
    COMMAND ${RTICODEGEN}
        -language C++98
        -update typefiles
        -d ${IDL_GEN_DIR}
        ${IDL_FILE}
    DEPENDS ${IDL_FILE}
    COMMENT "Generating type support code from message.idl"
)

# Publisher executable
add_executable(publisher
    publisher.cxx
    ${IDL_GEN_DIR}/message.cxx
    ${IDL_GEN_DIR}/messagePlugin.cxx
    ${IDL_GEN_DIR}/messageSupport.cxx
)

target_include_directories(publisher
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${IDL_GEN_DIR}
)

target_link_libraries(publisher
    nddscpp
    nddsc
    nddscore
    dl
    m
    pthread
    rt
)

# Subscriber executable
add_executable(subscriber
    subscriber.cxx
    ${IDL_GEN_DIR}/message.cxx
    ${IDL_GEN_DIR}/messagePlugin.cxx
    ${IDL_GEN_DIR}/messageSupport.cxx
)

target_include_directories(subscriber
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${IDL_GEN_DIR}
)

target_link_libraries(subscriber
    nddscpp
    nddsc
    nddscore
    dl
    m
    pthread
    rt
)

# Copy USER_QOS_PROFILES.xml to build directory
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/USER_QOS_PROFILES.xml
    ${CMAKE_CURRENT_BINARY_DIR}/USER_QOS_PROFILES.xml
    COPYONLY
)
