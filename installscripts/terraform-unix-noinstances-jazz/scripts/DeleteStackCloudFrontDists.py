import json
import os
import subprocess
import sys
import time

def listCFDistributions(fname):
    return subprocess.call('aws cloudfront list-distributions >> ' + fname , shell=True)

def checkCloudFrontExists(CFId, fname):
    return subprocess.call('aws cloudfront get-distribution-config --id ' + CFId + ' >> ' + fname , shell=True)

def getCloudFrontStatus(CFId, fname):
    return subprocess.call('aws cloudfront get-distribution --id ' + CFId + ' >> ' + fname , shell=True)

def deleteCloudFront(CFId, eTAG):
    print ("\tcalling delete of CloudFront Dist ( " + CFId + " )")
    retval = subprocess.call('aws cloudfront delete-distribution --id ' + CFId  + ' --if-match ' + eTAG, shell=True)
    if (retval == 0):
        print("\t\tSuccessfully deleted CloudFront Distribution ( " + CFId + " )")
    else:
        print("\t\tError deleting CloudFront Distribution ( " + CFId + " )")
    return retval

def disableCloudFront(CFId, eTAG, fname):
    return subprocess.call('aws cloudfront update-distribution --id ' + CFId  + ' --distribution-config file://' + fname +' --if-match ' + eTAG, shell=True)

def deleteFile(filenameToDel):
    try:
        os.remove(filenameToDel)
    except OSError:
        pass

def loadJsonFromFile(fileJson):
    fileOp = open(fileJson, 'r')
    jsonOp = json.load(fileOp, object_pairs_hook=OrderedDict)
    fileOp.close()
    return jsonOp
    

if(len(sys.argv) != 3):
    print ("Error - Please provide Argument1(Provide Stack Name)='stack name' Argument2(Run DISABLE only and dont delete distributions)='true/false'  ")
    print ("Argument1=<StackName> ")
    print ("Argument2=<true/false> ")
    exit(1)

if ((sys.argv[2].lower().__eq__("true")) or (sys.argv[2].lower().__eq__("false"))):
    print('')
else:
    print ('Argument 2 - Wrong argument option - should be true or false')
    exit(1)

stackName = sys.argv[1].lower() + "-"

from collections import OrderedDict

fdirectory = os.getcwd()
fnListContent = fdirectory + "/listdist.json"
deleteFile(fnListContent)

print ("Fetching Cloud Front Distributions and Running in Directory ==" + fdirectory)

listCFDistributions(fnListContent)

jsonCFDists = loadJsonFromFile(fnListContent)

print ("Done Fetching Cloud Front Distributions.")


#########################################################
#####First disable all the active Cloud Fronts###########
#########################################################
print ("Starting disabling of CF Distributions.....of stack==" + sys.argv[1].lower())

for cfDistItem in jsonCFDists['DistributionList']['Items']:
    if (cfDistItem['Origins']['Items'][0]['Id'].startswith(stackName)):
        filename = fdirectory + cfDistItem['Id'] + ".json"
        filestatus = fdirectory + cfDistItem['Id'] + "-status.json"
        deleteFile(filename)
        deleteFile(filestatus)
        
        #print(cfDistItem['Enabled'])
        #print(cfDistItem['Origins']['Items'][0]['Id'])
        retcode = checkCloudFrontExists(cfDistItem['Id'], filename)
        #print("retcode===" + str(retcode))
        cfReadyToDelete = False

        if (str(retcode).__eq__("0")) :
            jsonCFGetConfig = loadJsonFromFile(filename)
            
            #print ("Found Stack CF Distribution ( " + cfDistItem['Id'] + " ) with enabled==" + str(jsonCFGetConfig['DistributionConfig']['Enabled']))
            if (jsonCFGetConfig['DistributionConfig']['Enabled'] == True):
                jsonCFGetConfig['DistributionConfig']['Enabled'] = False
                print ("Found Stack CF Distribution  ( " + cfDistItem['Id'] + " ) that needs to be disabled")
                fileDistDisable = cfDistItem['Id'] + ".json"
                deleteFile(fileDistDisable)

                with open(fileDistDisable, 'a') as the_file:
                    the_file.write(json.dumps(jsonCFGetConfig['DistributionConfig'], sort_keys=False, indent=4))
    
                retval = disableCloudFront(cfDistItem['Id'], jsonCFGetConfig['ETag'], fileDistDisable)
                if (retval == 0):
                    print ("Dist ( " + cfDistItem['Id'] + " ) Disable has been called successfully..... ")
                else:
                    print ("ERROR Dist ( " + cfDistItem['Id'] + " ) Disable call was NOT successful ERROR.")

        else:
            print ("Error Fetching Dist ( " + cfDistItem['Id'] + " ) details.....continuing")

print ("Finished disabling of CF Distributions.....of stack==" + sys.argv[1].lower() + "\r\n\r\n")

if (sys.argv[2].lower().__eq__("true")):
    exit(0)

#########################################################
###Then continue deleting the CloudFront Distributions###
#########################################################

print ("Starting deleting of CF Distributions.....of stack==" + sys.argv[1].lower())

jsonCFDists = loadJsonFromFile(fnListContent)

for cfDistItem in jsonCFDists['DistributionList']['Items']:
    if (cfDistItem['Origins']['Items'][0]['Id'].startswith(stackName)):
        filename = fdirectory + cfDistItem['Id'] + ".json"
        filestatus = fdirectory + cfDistItem['Id'] + "-status.json"
        deleteFile(filename)
        deleteFile(filestatus)
        
        #print(cfDistItem['Enabled'])
        #print(cfDistItem['Origins']['Items'][0]['Id'])
        retcode = checkCloudFrontExists(cfDistItem['Id'], filename)
        #print("retcode===" + str(retcode))
        cfReadyToDelete = False

        if (str(retcode).__eq__("0")) :
            jsonCFGetConfig = loadJsonFromFile(filename)
            print ("\tStarted on CloudFront Distribution ( " + cfDistItem['Id'] + " ) which is enabled==" + str(jsonCFGetConfig['DistributionConfig']['Enabled']))
            if (jsonCFGetConfig['DistributionConfig']['Enabled'] == True):
                jsonCFGetConfig['DistributionConfig']['Enabled'] = False
                print ("\t\tFirst Disabling the Cloud Front Distribution ( " + cfDistItem['Id'] + " ) set enabled==" + str(jsonCFGetConfig['DistributionConfig']['Enabled']))
                cfDistFile = cfDistItem['Id'] + ".json"
                deleteFile(cfDistFile)

                with open(cfDistFile, 'a') as the_file:
                    the_file.write(json.dumps(jsonCFGetConfig['DistributionConfig'], sort_keys=False, indent=4))
    
                disableCloudFront(cfDistItem['Id'], jsonCFGetConfig['ETag'], cfDistFile)
                
                while (cfReadyToDelete == False):
                    deleteFile(filestatus)
                    getCloudFrontStatus(cfDistItem['Id'], filestatus)
                    valuesStatus = loadJsonFromFile(filestatus)
                    if (valuesStatus['Distribution']['Status']=="InProgress"):
                        cfReadyToDelete = False
                        print ("\t\t\tsleeping for 30 secs (POST Disabling) on ::" + cfDistItem['Id'])
                        time.sleep(30)
                        print ("\t\t\tAwake and checking on::" + cfDistItem['Id'])
                    else:
                        cfReadyToDelete = True

                retval = deleteCloudFront(cfDistItem['Id'], jsonCFGetConfig['ETag']);

            else:
                while (cfReadyToDelete == False):
                    try:
                        os.remove(filestatus)
                    except OSError:
                        pass
                    
                    getCloudFrontStatus(cfDistItem['Id'], filestatus)
                    valuesStatus = loadJsonFromFile(filestatus)
                    if (valuesStatus['Distribution']['Status']=="InProgress"):
                        cfReadyToDelete = False
                        print ("\t\tsleeping for 30 secs (WAITING To DELETE)::" + cfDistItem['Id'])
                        time.sleep(30)
                        print ("\t\tAwake and checking on::" + cfDistItem['Id'])
                    else:
                        cfReadyToDelete = True

                retval = deleteCloudFront(cfDistItem['Id'], jsonCFGetConfig['ETag']);

print ("Completed deleting of CF Distributions.....of stack==" + sys.argv[1].lower())
