#!/bin/bash

# Valgrind profiling and debugging tools wrapper
# Usage: ./valgrind.sh [tool] [app] [domain_id] [sample_count]
#        ./valgrind.sh  (shows help)

# Show help if no arguments or help requested
if [ $# -eq 0 ] || [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Valgrind Tools Wrapper"
    echo ""
    echo "Usage:"
    echo "  ./valgrind.sh [tool] [app] [domain_id] [sample_count]"
    echo ""
    echo "Tools:"
    echo "  callgrind    - Call graph profiler (performance profiling)"
    echo "  memcheck     - Memory error detector (memory leaks, invalid access)"
    echo "  massif       - Heap profiler (memory usage over time)"
    echo "  cachegrind   - Cache profiler (L1/L2 cache performance)"
    echo "  helgrind     - Thread error detector (data races, deadlocks)"
    echo "  drd          - Thread error detector (alternative to helgrind)"
    echo ""
    echo "Examples:"
    echo "  ./valgrind.sh callgrind publisher 0 10"
    echo "  ./valgrind.sh memcheck publisher 0 10"
    echo "  ./valgrind.sh massif subscriber 0 10"
    echo "  ./valgrind.sh cachegrind publisher 0 10"
    echo ""
    echo "Output files are saved in the current directory:"
    echo "  callgrind:   [app].callgrind.out"
    echo "  memcheck:   [app].memcheck.log"
    echo "  massif:      massif.out.[pid]"
    echo "  cachegrind:  cachegrind.out.[pid]"
    echo "  helgrind:    helgrind.out.[pid]"
    echo "  drd:         drd.out.[pid]"
    exit 0
fi

TOOL=$1
APP=${2:-publisher}
DOMAIN_ID=${3:-0}
SAMPLE_COUNT=${4:-10}

# Validate tool
VALID_TOOLS="callgrind memcheck massif cachegrind helgrind drd"
if [[ ! " $VALID_TOOLS " =~ " $TOOL " ]]; then
    echo "Error: Invalid tool '$TOOL'"
    echo "Valid tools: $VALID_TOOLS"
    echo "Run './valgrind.sh' for help"
    exit 1
fi

# Check if executable exists
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

echo "Running ${APP} with Valgrind ${TOOL}..."
echo "Domain ID: ${DOMAIN_ID}, Sample Count: ${SAMPLE_COUNT}"
echo ""

# Run with appropriate tool
case $TOOL in
    callgrind)
        echo "Profiling call graph (this may take longer)..."
        valgrind --tool=callgrind \
            --callgrind-out-file=${APP}.callgrind.out \
            --dump-instr=yes \
            --collect-jumps=yes \
            ./build/${APP} -d ${DOMAIN_ID} -s ${SAMPLE_COUNT}
        
        echo ""
        echo "Callgrind data saved: ${APP}.callgrind.out"
        
        # Check if kcachegrind is available
        if command -v kcachegrind &> /dev/null; then
            echo "Opening with kcachegrind (GUI)..."
            kcachegrind ${APP}.callgrind.out &
        else
            echo ""
            echo "To view results:"
            echo "  kcachegrind ${APP}.callgrind.out"
            echo "  callgrind_annotate ${APP}.callgrind.out | less"
        fi
        ;;
    
    memcheck)
        echo "Checking for memory errors..."
        valgrind --tool=memcheck \
            --leak-check=full \
            --show-leak-kinds=all \
            --track-origins=yes \
            --verbose \
            --log-file=${APP}.memcheck.log \
            ./build/${APP} -d ${DOMAIN_ID} -s ${SAMPLE_COUNT}
        
        echo ""
        echo "Memcheck log saved: ${APP}.memcheck.log"
        echo ""
        echo "Summary:"
        grep -E "(ERROR SUMMARY|LEAK SUMMARY|definitely lost|indirectly lost|possibly lost)" ${APP}.memcheck.log | tail -10
        echo ""
        echo "View full log: less ${APP}.memcheck.log"
        ;;
    
    massif)
        echo "Profiling heap usage..."
        valgrind --tool=massif \
            --massif-out-file=${APP}.massif.out \
            ./build/${APP} -d ${DOMAIN_ID} -s ${SAMPLE_COUNT}
        
        echo ""
        echo "Massif data saved: ${APP}.massif.out"
        echo ""
        echo "To view results:"
        echo "  ms_print ${APP}.massif.out | less"
        echo "  Or use massif-visualizer: massif-visualizer ${APP}.massif.out"
        ;;
    
    cachegrind)
        echo "Profiling cache performance..."
        valgrind --tool=cachegrind \
            --cachegrind-out-file=${APP}.cachegrind.out \
            ./build/${APP} -d ${DOMAIN_ID} -s ${SAMPLE_COUNT}
        
        echo ""
        echo "Cachegrind data saved: ${APP}.cachegrind.out"
        echo ""
        echo "To view results:"
        echo "  cg_annotate ${APP}.cachegrind.out | less"
        echo "  cg_diff [file1] [file2]  (compare two runs)"
        ;;
    
    helgrind)
        echo "Checking for thread errors (data races, deadlocks)..."
        valgrind --tool=helgrind \
            --log-file=${APP}.helgrind.log \
            ./build/${APP} -d ${DOMAIN_ID} -s ${SAMPLE_COUNT}
        
        echo ""
        echo "Helgrind log saved: ${APP}.helgrind.log"
        echo ""
        echo "View results: less ${APP}.helgrind.log"
        ;;
    
    drd)
        echo "Checking for thread errors (alternative to helgrind)..."
        valgrind --tool=drd \
            --log-file=${APP}.drd.log \
            ./build/${APP} -d ${DOMAIN_ID} -s ${SAMPLE_COUNT}
        
        echo ""
        echo "DRD log saved: ${APP}.drd.log"
        echo ""
        echo "View results: less ${APP}.drd.log"
        ;;
esac

echo ""
echo "Done!"
