import subprocess
import json


def delete_event_source_mapping(stackName):
    """
        This method will list out the function mapping and
        then delete the event source mapping
    """

    print("Deleting EventSourceMappings for StackName: {0}".format(stackName))

    # Deleting Event Source Mapping for handler dev
    event_source_function = stackName + "-hndlr-dev"

    try:
        print "Listing Event source mapping for function " + event_source_function
        list_event_output = subprocess.check_output([
            "aws", "lambda", "list-event-source-mappings", "--function-name",
            event_source_function
        ])
        print list_event_output

        # Parser the json payload
        json_parse = json.loads(list_event_output)
        if json_parse is not None and len(
                json_parse['EventSourceMappings']) > 0:
            uuid = json_parse['EventSourceMappings'][0]['UUID']
            print "uuid " + uuid

            # Deleting the Event source mapping
            delete_event_output = subprocess.check_output([
                "aws", "lambda", "delete-event-source-mapping", "--uuid", uuid
            ])
            print delete_event_output
        else:
            print("No Event source mapping found")
    except Exception as e:
        print e
