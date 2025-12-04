#!/bin/bash

# Profile using Valgrind callgrind
# Usage: ./profile_valgrind.sh [publisher|subscriber] [domain_id] [sample_count]

APP=${1:-publisher}
DOMAIN_ID=${2:-0}
SAMPLE_COUNT=${3:-10}

if [ ! -f "./build/${APP}" ]; then
    echo "Error: ./build/${APP} not found. Please build first with ./build.sh"
    exit 1
fi

# Check if valgrind is available
if ! command -v valgrind &> /dev/null; then
    echo "Error: valgrind is not installed"
    echo "Install with: sudo apt-get install valgrind"
    exit 1
fi

# Check if kcachegrind is available (optional, for GUI)
HAS_KCACHEGRIND=false
if command -v kcachegrind &> /dev/null; then
    HAS_KCACHEGRIND=true
fi

echo "Profiling ${APP} with Valgrind callgrind..."
echo "Domain ID: ${DOMAIN_ID}, Sample Count: ${SAMPLE_COUNT}"
echo ""

# Create output directory
mkdir -p profiling_results

# Run with callgrind
echo "Running with callgrind (this may take longer)..."
valgrind --tool=callgrind \
    --callgrind-out-file=profiling_results/${APP}.callgrind.out \
    --dump-instr=yes \
    --collect-jumps=yes \
    ./build/${APP} -d ${DOMAIN_ID} -s ${SAMPLE_COUNT}

echo ""
echo "Callgrind data saved: profiling_results/${APP}.callgrind.out"
echo ""

if [ "$HAS_KCACHEGRIND" = true ]; then
    echo "Opening with kcachegrind (GUI)..."
    kcachegrind profiling_results/${APP}.callgrind.out &
else
    echo "To view results:"
    echo "  1. Install kcachegrind: sudo apt-get install kcachegrind"
    echo "  2. Open: kcachegrind profiling_results/${APP}.callgrind.out"
    echo ""
    echo "Or use callgrind_annotate for text output:"
    echo "  callgrind_annotate profiling_results/${APP}.callgrind.out | less"
fi

