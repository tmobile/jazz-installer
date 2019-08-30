import json
import subprocess
import os
import os.path


def checkCFServiceAvailable(servicename):
    return subprocess.call(
        "aws cloudformation list-stack-resources --stack-name " + servicename + " --region " + region,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)


def deleteCFService(servicename):
    return subprocess.call(
        "aws cloudformation delete-stack --stack-name " + servicename + " --region " + region,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)


def getServicesList():
    return subprocess.call(
        'aws cloudformation list-stacks --region ' + region + ' --stack-status-filter \
        "CREATE_IN_PROGRESS" "CREATE_FAILED" "CREATE_COMPLETE" "UPDATE_IN_PROGRESS" "UPDATE_COMPLETE" \
        >> listservice.json',
        shell=True)


def deleteCloudFormationService(service_name):
    return_code = checkCFServiceAvailable(service_name)
    if return_code == 0:
        print("Service::" + service_name +
              ": exists. Service deletion started.........")
        delete_return_code = deleteCFService(service_name)
        if delete_return_code == 0:
            print("\tSuccessfully deleted service " + service_name)
        else:
            print("\tError while deleting service " + service_name +
                  " errorcode=" + delete_return_code)
    else:
        print('Error service not found::' + service_name)


def delete_platform_services(stackname, region_name, deleteClientServices=False):
    global region
    region = region_name
    print("\r\nStarting deletion of micro services\r\n\r\n")

    # Delete user services Cloud formations
    fname = 'listservice.json'
    if os.path.isfile(fname):
        os.remove(fname)

    valresp = getServicesList()
    if (valresp != 0):
        exit(1)

    jsonFile = open(fname, 'r')
    values = json.load(jsonFile)
    jsonFile.close()

    ss = values['StackSummaries']

    for item in ss:
        if (item['StackName'].startswith(stackname)):
            deleteCloudFormationService(item['StackName'])
