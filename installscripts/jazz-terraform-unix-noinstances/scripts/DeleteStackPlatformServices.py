#!/usr/bin/python
import json
import sys
import subprocess
import os
import os.path

def checkCFServiceAvailable(servicename):
    return subprocess.call("aws cloudformation list-stack-resources --stack-name " + servicename, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def deleteCFService(servicename):
    return subprocess.call("aws cloudformation delete-stack --stack-name " + servicename, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    #return subprocess.call("aws cloudformation list-stack-resources --stack-name " + servicename, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def getServicesList():
    return subprocess.call('aws cloudformation list-stacks --stack-status-filter "CREATE_IN_PROGRESS" "CREATE_FAILED" "CREATE_COMPLETE" "UPDATE_IN_PROGRESS" "UPDATE_COMPLETE" >> listservice.json', shell=True)

def deleteCloudFormationService(service_name):
    return_code = checkCFServiceAvailable(service_name)
    if return_code == 0 :
        print ("Service::" + service_name + ": exists. Service deletion started.........")
        delete_return_code = deleteCFService(service_name)
        if delete_return_code == 0 :
            print ("\tSuccessfully Deleted service " + service_name)
        else :
            print ("\tError while Deleting service " + service_name + " errorcode=" + delete_return_code)
    else:
        print ('Error Service not found::' + service_name)


if(len(sys.argv) != 3):
    print ("Error - Please provide Argument1='stack name' and Argument1='Delete Client servies option true or false' ")
    print ("Argument1=<StackName> Argument2=<true/false>")
    exit(1)

print (str(sys.argv))

stackName = sys.argv[1].lower() + "-"
deleteClientServices = sys.argv[2]

platformServices = ['jazz_cognito-authorizer', 'jazz_logs', 'jazz_usermanagement', 'jazz_services-handler', 'jazz_events', 'jazz_services', 'jazz_logout', 'jazz_login', 'jazz_cloud-logs-streamer', 'jazz_is-service-available', 'jazz_delete-serverless-service', 'jazz_create-serverless-service', 'jazz_email', 'jazz_events-handler']

for pservice in platformServices:
    deleteCloudFormationService(stackName + pservice)

print ("\r\n\r\nCompleted Deletion Platform services.")

if (deleteClientServices.lower() != 'true'):
    exit(0)

print ("\r\nStarting deletions of Client Services\r\n\r\n")

## Delete user services Cloud formations 
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


spLen = len(stackName)

inval = 0;
for item in ss:
    if (item['StackName'].startswith(stackName)):
        #print(item['StackName'][spLen:len(item['StackName'])])
        if item['StackName'][spLen:len(item['StackName'])] not in platformServices:
            deleteCloudFormationService(item['StackName'])
