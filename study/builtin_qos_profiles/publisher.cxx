/*
 * Simple publisher demonstrating built-in QoS profiles
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

int run_publisher_application(unsigned int domain_id, unsigned int sample_count)
{
    DDS_Duration_t send_period = { 1, 0 };  // 1 second

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

    // Create publisher
    DDSPublisher *publisher = participant->create_publisher(
            DDS_PUBLISHER_QOS_DEFAULT,
            NULL,
            DDS_STATUS_MASK_NONE);
    if (publisher == NULL) {
        return shutdown_participant(
                participant,
                "create_publisher error",
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

    // Create DataWriter with default QoS
    DDSDataWriter *untyped_writer = publisher->create_datawriter(
            topic,
            DDS_DATAWRITER_QOS_DEFAULT,
            NULL,
            DDS_STATUS_MASK_NONE);
    if (untyped_writer == NULL) {
        return shutdown_participant(
                participant,
                "create_datawriter error",
                EXIT_FAILURE);
    }

    // Narrow to typed writer
    MessageDataWriter *typed_writer =
            MessageDataWriter::narrow(untyped_writer);
    if (typed_writer == NULL) {
        return shutdown_participant(
                participant,
                "DataWriter narrow error",
                EXIT_FAILURE);
    }

    // Create data sample
    Message *data = MessageTypeSupport::create_data();
    if (data == NULL) {
        return shutdown_participant(
                participant,
                "MessageTypeSupport::create_data error",
                EXIT_FAILURE);
    }

    // Main loop - write data
    std::cout << "Publisher started. Writing samples..." << std::endl;
    for (unsigned int count = 0;
         !shutdown_requested && count < sample_count;
         ++count) {

        // Set data values
        data->id = count;
        char buffer[256];
        sprintf(buffer, "Hello World! Count: %d", count);
        data->content = DDS_String_dup(buffer);

        std::cout << "Writing Message: id=" << data->id
                  << ", content=\"" << data->content << "\"" << std::endl;

        // Write sample
        retcode = typed_writer->write(*data, DDS_HANDLE_NIL);
        if (retcode != DDS_RETCODE_OK) {
            std::cerr << "write error " << retcode << std::endl;
        }

        NDDSUtility::sleep(send_period);
    }

    // Cleanup
    retcode = MessageTypeSupport::delete_data(data);
    if (retcode != DDS_RETCODE_OK) {
        std::cerr << "MessageTypeSupport::delete_data error " << retcode
                  << std::endl;
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
    int status = run_publisher_application(
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
