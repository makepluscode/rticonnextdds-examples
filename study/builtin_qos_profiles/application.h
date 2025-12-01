/*
 * Application utilities for signal handling and argument parsing
 */

#ifndef APPLICATION_H
#define APPLICATION_H

#include <iostream>
#include <csignal>
#include <cstdlib>
#include <climits>

namespace application {

// Global flag for shutdown
bool shutdown_requested = false;

inline void stop_handler(int)
{
    shutdown_requested = true;
    std::cout << "Preparing to shut down..." << std::endl;
}

inline void setup_signal_handlers()
{
    signal(SIGINT, stop_handler);
    signal(SIGTERM, stop_handler);
}

enum ParseReturn {
    PARSE_RETURN_OK,
    PARSE_RETURN_FAILURE,
    PARSE_RETURN_EXIT
};

struct ApplicationArguments {
    ParseReturn parse_result;
    unsigned int domain_id;
    unsigned int sample_count;
};

inline void parse_arguments(
        ApplicationArguments &arguments,
        int argc,
        char *argv[])
{
    int arg_processing = 1;
    bool show_usage = false;
    arguments.domain_id = 0;
    arguments.sample_count = INT_MAX;
    arguments.parse_result = PARSE_RETURN_OK;

    while (arg_processing < argc) {
        if ((argc > arg_processing + 1)
            && (strcmp(argv[arg_processing], "-d") == 0)) {
            arguments.domain_id = atoi(argv[arg_processing + 1]);
            arg_processing += 2;
        } else if (
                (argc > arg_processing + 1)
                && (strcmp(argv[arg_processing], "-s") == 0)) {
            arguments.sample_count = atoi(argv[arg_processing + 1]);
            arg_processing += 2;
        } else if (strcmp(argv[arg_processing], "-h") == 0) {
            show_usage = true;
            arguments.parse_result = PARSE_RETURN_EXIT;
            break;
        } else {
            std::cout << "Bad parameter." << std::endl;
            show_usage = true;
            arguments.parse_result = PARSE_RETURN_FAILURE;
            break;
        }
    }

    if (show_usage) {
        std::cout << "Usage:\n"
                     "    -d <int>   Domain ID (default: 0)\n"
                     "    -s <int>   Number of samples (default: infinite)\n"
                     "    -h         Show this help\n"
                  << std::endl;
    }
}

}  // namespace application

#endif  // APPLICATION_H
