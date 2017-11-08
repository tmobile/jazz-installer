import sys
import subprocess

#return_code = subprocess.call("aws cloudformation list-stack-resources --stack-name test2-stack", shell=True)
#/print (return_code)

def checkCFServiceAvailable(servicename):
    return subprocess.call("aws cloudformation list-stack-resources --stack-name " + servicename, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def deleteCFService(servicename):
    return subprocess.call("aws cloudformation delete-stack --stack-name " + servicename, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

if(len(sys.argv) != 2):
    print ("Error - Please provide stack name")
    exit(1)

print (str(sys.argv))

stackName = sys.argv[1] + "-"

platformServices = ['hndlr-dev', 'events-dev', 'services-dev', 'logout-dev', 'login-dev', 'cloud-logs-streamer-dev', 'is-service-available-dev', 'delete-serverless-service-dev', 'create-serverless-service-dev', 'cognito-authorizer-dev']
for pservice in platformServices:
    service_name = stackName + pservice
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
