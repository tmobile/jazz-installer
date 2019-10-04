def delete_event_source_mapping(stackName, client):
    """
        This method will list out the function mapping and
        then delete the event source mapping
    """

    print("Deleting EventSourceMappings for StackName: {0}".format(stackName))

    # Deleting Event Source Mapping for handler dev
    event_source_function = stackName + "-hndlr-dev"

    try:
        print("Listing Event source mapping for function " + event_source_function)
        list_event_output = client.list_event_source_mappings(
            FunctionName=event_source_function,
        )
        print(list_event_output)

        if list_event_output is not None and len(
                list_event_output['EventSourceMappings']) > 0:
            uuid = list_event_output['EventSourceMappings'][0]['UUID']
            print("uuid " + uuid)

            # Deleting the Event source mapping
            delete_event_output = client.delete_event_source_mapping(UUID=uuid)
            print(delete_event_output)
        else:
            print("No Event source mapping found")
    except Exception as e:
        print(e)
