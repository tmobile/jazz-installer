def checkCFServiceAvailable(servicename):
    try:
        return cform_client.list_stack_resources(StackName=servicename)
    except Exception:
        return False


def deleteCFService(servicename):
    try:
        return cform_client.delete_stack(StackName=servicename)
    except Exception:
        return False


def getServicesList():
    paginator = cform_client.get_paginator('list_stacks')
    return paginator.paginate(StackStatusFilter=["CREATE_IN_PROGRESS",
                                                 "CREATE_FAILED",
                                                 "CREATE_COMPLETE",
                                                 "UPDATE_IN_PROGRESS",
                                                 "UPDATE_COMPLETE"])


def deleteCloudFormationService(service_name):
    return_code = checkCFServiceAvailable(service_name)
    if return_code is not False:
        print("Service::" + service_name +
              ": exists. Service deletion started.........")
        delete_return_code = deleteCFService(service_name)
        if delete_return_code is not False:
            print("\tSuccessfully deleted service " + service_name)
        else:
            print("\tError while deleting service " + service_name)
    else:
        print('Error service not found::' + service_name)


def delete_platform_services(stackname, client, deleteClientServices=False):
    global cform_client
    cform_client = client
    print("\r\nStarting deletion of micro services\r\n\r\n")

    # Delete user services Cloud formations
    valresp = getServicesList()
    for page in valresp:
        stack = page['StackSummaries']
        for output in stack:
            if (output['StackName'].startswith(stackname)):
                deleteCloudFormationService(output['StackName'])
