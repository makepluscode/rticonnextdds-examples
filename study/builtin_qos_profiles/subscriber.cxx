/*
 * Simple subscriber demonstrating built-in QoS profiles
 */

#include <iostream>
#include <stdio.h>
#include <stdlib.h>

#include "message.h"
#include "messageSupport.h"
#include "ndds/ndds_cpp.h"
#include "application.h"

using namespace application;

static int shutdown_participant(
        DDSDomainParticipant *participant,
        const char *shutdown_message,
        int status);

unsigned int process_data(MessageDataReader *typed_reader)
{
    MessageSeq data_seq;
    DDS_SampleInfoSeq info_seq;
    unsigned int samples_read = 0;

    // Take available data
    typed_reader->take(
            data_seq,
            info_seq,
            DDS_LENGTH_UNLIMITED,
            DDS_ANY_SAMPLE_STATE,
            DDS_ANY_VIEW_STATE,
            DDS_ANY_INSTANCE_STATE);

    // Process each sample
    for (int i = 0; i < data_seq.length(); ++i) {
        if (info_seq[i].valid_data) {
            samples_read++;
            std::cout << "Received Message: id=" << data_seq[i].id
                      << ", content=\"" << data_seq[i].content << "\""
                      << std::endl;
        }
    }

    // Return loan
    DDS_ReturnCode_t retcode = typed_reader->return_loan(data_seq, info_seq);
    if (retcode != DDS_RETCODE_OK) {
        std::cerr << "return loan error " << retcode << std::endl;
    }

    return samples_read;
}

int run_subscriber_application(
        unsigned int domain_id,
        unsigned int sample_count)
{
    DDS_Duration_t wait_timeout = { 1, 0 };  // 1 second

    /*
     * Enable network capture.
     *
     * This must be called before:
     *   - Any other network capture function is called.
     *   - Creating the participants for which we want to capture traffic.
     */
    if (!NDDSUtilityNetworkCapture::enable()) {
        std::cerr << "Error enabling network capture" << std::endl;
        return EXIT_FAILURE;
    }

    // Create participant using default QoS from USER_QOS_PROFILES.xml
    // This will use the BuiltinQosLibExp::Pattern.ReliableStreaming profile
    DDSDomainParticipant *participant =
            DDSTheParticipantFactory->create_participant(
                    domain_id,
                    DDS_PARTICIPANT_QOS_DEFAULT,
                    NULL,
                    DDS_STATUS_MASK_NONE);
    if (participant == NULL) {
        return shutdown_participant(
                participant,
                "create_participant error",
                EXIT_FAILURE);
    }

    /*
     * Start capturing traffic for all participants.
     *
     * All participants: those already created and those yet to be created.
     * Default parameters: all transports and some other sane defaults.
     *
     * A capture file will be created for each participant. The capture file
     * will start with the prefix "subscriber" and continue with a suffix
     * dependent on the participant's GUID.
     */
    if (!NDDSUtilityNetworkCapture::start("subscriber")) {
        std::cerr << "Error starting network capture" << std::endl;
        return shutdown_participant(
                participant,
                "Error starting network capture",
                EXIT_FAILURE);
    }

    // Create subscriber
    DDSSubscriber *subscriber = participant->create_subscriber(
            DDS_SUBSCRIBER_QOS_DEFAULT,
            NULL,
            DDS_STATUS_MASK_NONE);
    if (subscriber == NULL) {
        return shutdown_participant(
                participant,
                "create_subscriber error",
                EXIT_FAILURE);
    }

    // Register the datatype
    const char *type_name = MessageTypeSupport::get_type_name();
    DDS_ReturnCode_t retcode =
            MessageTypeSupport::register_type(participant, type_name);
    if (retcode != DDS_RETCODE_OK) {
        return shutdown_participant(
                participant,
                "register_type error",
                EXIT_FAILURE);
    }

    // Create topic
    DDSTopic *topic = participant->create_topic(
            "MessageTopic",
            type_name,
            DDS_TOPIC_QOS_DEFAULT,
            NULL,
            DDS_STATUS_MASK_NONE);
    if (topic == NULL) {
        return shutdown_participant(
                participant,
                "create_topic error",
                EXIT_FAILURE);
    }

    // Create DataReader with default QoS
    DDSDataReader *untyped_reader = subscriber->create_datareader(
            topic,
            DDS_DATAREADER_QOS_DEFAULT,
            NULL,
            DDS_STATUS_MASK_NONE);
    if (untyped_reader == NULL) {
        return shutdown_participant(
                participant,
                "create_datareader error",
                EXIT_FAILURE);
    }

    // Narrow to typed reader
    MessageDataReader *typed_reader =
            MessageDataReader::narrow(untyped_reader);
    if (typed_reader == NULL) {
        return shutdown_participant(
                participant,
                "DataReader narrow error",
                EXIT_FAILURE);
    }

    // Create read condition
    DDSReadCondition *read_condition = typed_reader->create_readcondition(
            DDS_NOT_READ_SAMPLE_STATE,
            DDS_ANY_VIEW_STATE,
            DDS_ANY_INSTANCE_STATE);
    if (read_condition == NULL) {
        return shutdown_participant(
                participant,
                "create_readcondition error",
                EXIT_FAILURE);
    }

    // Main loop - wait for data
    std::cout << "Subscriber started. Waiting for samples..." << std::endl;
    unsigned int samples_read = 0;
    while (!shutdown_requested && samples_read < sample_count) {
        // Wait for data using read condition
        DDSConditionSeq active_conditions_seq;
        DDSWaitSet waitset;
        waitset.attach_condition(read_condition);

        retcode = waitset.wait(active_conditions_seq, wait_timeout);
        waitset.detach_condition(read_condition);

        if (retcode == DDS_RETCODE_OK) {
            // Data is available
            samples_read += process_data(typed_reader);
        } else if (retcode == DDS_RETCODE_TIMEOUT) {
            // No data received, continue waiting
            continue;
        } else {
            std::cerr << "wait error " << retcode << std::endl;
            break;
        }
    }

    /*
     * Before deleting the participants that are capturing, we must stop
     * network capture for them.
     */
    if (!NDDSUtilityNetworkCapture::stop()) {
        std::cerr << "Error stopping network capture" << std::endl;
    }

    // Cleanup read condition
    retcode = typed_reader->delete_readcondition(read_condition);
    if (retcode != DDS_RETCODE_OK) {
        std::cerr << "delete_readcondition error " << retcode << std::endl;
    }

    return shutdown_participant(participant, "Shutting down", EXIT_SUCCESS);
}

static int shutdown_participant(
        DDSDomainParticipant *participant,
        const char *shutdown_message,
        int status)
{
    DDS_ReturnCode_t retcode;

    std::cout << shutdown_message << std::endl;

    if (participant != NULL) {
        retcode = participant->delete_contained_entities();
        if (retcode != DDS_RETCODE_OK) {
            std::cerr << "delete_contained_entities error " << retcode
                      << std::endl;
            status = EXIT_FAILURE;
        }

        retcode = DDSTheParticipantFactory->delete_participant(participant);
        if (retcode != DDS_RETCODE_OK) {
            std::cerr << "delete_participant error " << retcode << std::endl;
            status = EXIT_FAILURE;
        }
    }

    return status;
}

int main(int argc, char *argv[])
{
    // Parse arguments
    ApplicationArguments arguments;
    parse_arguments(arguments, argc, argv);
    if (arguments.parse_result == PARSE_RETURN_EXIT) {
        return EXIT_SUCCESS;
    } else if (arguments.parse_result == PARSE_RETURN_FAILURE) {
        return EXIT_FAILURE;
    }

    // Setup signal handlers
    setup_signal_handlers();

    // Run application
    int status = run_subscriber_application(
            arguments.domain_id,
            arguments.sample_count);

    // Finalize
    DDS_ReturnCode_t retcode = DDSDomainParticipantFactory::finalize_instance();
    if (retcode != DDS_RETCODE_OK) {
        std::cerr << "finalize_instance error " << retcode << std::endl;
        status = EXIT_FAILURE;
    }

    return status;
}
