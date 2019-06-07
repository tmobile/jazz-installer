import json
import os
import subprocess
import time
from collections import OrderedDict


def listCFDistributions(fname):
    return subprocess.call(
        'aws cloudfront list-distributions >> ' + fname, shell=True)


def checkCloudFrontExists(CFId, fname):
    return subprocess.call(
        'aws cloudfront get-distribution-config --id ' + CFId + ' >> ' + fname,
        shell=True)


def getCloudFrontStatus(CFId, fname):
    return subprocess.call(
        'aws cloudfront get-distribution --id ' + CFId + ' >> ' + fname,
        shell=True)


def deleteCloudFront(CFId, eTAG):
    print("\tcalling delete of CloudFront Dist ( " + CFId + " )")
    retval = subprocess.call(
        'aws cloudfront delete-distribution --id ' + CFId + ' --if-match ' +
        eTAG,
        shell=True)
    if (retval == 0):
        print("\t\tSuccessfully deleted CloudFront Distribution ( " + CFId +
              " )")
    else:
        print("\t\tError deleting CloudFront Distribution ( " + CFId + " )")
    return retval


def disableCloudFront(CFId, eTAG, fname):
    return subprocess.call(
        'aws cloudfront update-distribution --id ' + CFId +
        ' --distribution-config file://' + fname + ' --if-match ' + eTAG,
        shell=True)


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


def delete_cf_dists(stackname, deletedists=False):
    fdirectory = os.getcwd()
    fnListContent = fdirectory + "/listdist.json"
    deleteFile(fnListContent)

    print("Fetching Cloud Front Distributions")

    listCFDistributions(fnListContent)

    jsonCFDists = loadJsonFromFile(fnListContent)

    print("Done Fetching Cloud Front Distributions.")

    # First disable all the active Cloud Fronts             #
    print("Starting disable of CF Distributions for stack: {0}".format(
        stackname))

    for cfDistItem in jsonCFDists['DistributionList']['Items']:
        if (cfDistItem['Origins']['Items'][0]['Id'].startswith(stackname)):
            filename = fdirectory + cfDistItem['Id'] + ".json"
            filestatus = fdirectory + cfDistItem['Id'] + "-status.json"
            deleteFile(filename)
            deleteFile(filestatus)

            retcode = checkCloudFrontExists(cfDistItem['Id'], filename)
            cfReadyToDelete = False

            if (str(retcode).__eq__("0")):
                jsonCFGetConfig = loadJsonFromFile(filename)

                if (jsonCFGetConfig['DistributionConfig']['Enabled'] is True):
                    jsonCFGetConfig['DistributionConfig']['Enabled'] = False
                    print("Found Stack CF Distribution  ( " +
                          cfDistItem['Id'] + " ) that needs to be disabled")
                    fileDistDisable = cfDistItem['Id'] + ".json"
                    deleteFile(fileDistDisable)

                    with open(fileDistDisable, 'a') as the_file:
                        the_file.write(
                            json.dumps(
                                jsonCFGetConfig['DistributionConfig'],
                                sort_keys=False,
                                indent=4))

                    retval = disableCloudFront(cfDistItem['Id'],
                                               jsonCFGetConfig['ETag'],
                                               fileDistDisable)
                    if (retval == 0):
                        print("Dist ( " + cfDistItem['Id'] +
                              " ) Disable has been called successfully..... ")
                    else:
                        print("ERROR Dist ( " + cfDistItem['Id'] +
                              " ) Disable call was NOT successful ERROR.")

            else:
                print("Error Fetching Dist ( " + cfDistItem['Id'] +
                      " ) details.....continuing")

    print("Finished disabling of CF Distributions for stack: {0}".format(
        stackname))

    if not deletedists:
        return

    # Keep going, we're disabling + deleting
    # Then continue deleting the CloudFront Distributions

    print("Starting deletion of CF Distributions for stack: {0}".format(
        stackname))

    jsonCFDists = loadJsonFromFile(fnListContent)

    for cfDistItem in jsonCFDists['DistributionList']['Items']:
        if (cfDistItem['Origins']['Items'][0]['Id'].startswith(stackname)):
            filename = fdirectory + cfDistItem['Id'] + ".json"
            filestatus = fdirectory + cfDistItem['Id'] + "-status.json"
            deleteFile(filename)
            deleteFile(filestatus)

            retcode = checkCloudFrontExists(cfDistItem['Id'], filename)
            cfReadyToDelete = False

            if (str(retcode).__eq__("0")):
                jsonCFGetConfig = loadJsonFromFile(filename)
                print("\tStarted on CloudFront Distribution ( " +
                      cfDistItem['Id'] + " ) which is enabled==" +
                      str(jsonCFGetConfig['DistributionConfig']['Enabled']))
                if (jsonCFGetConfig['DistributionConfig']['Enabled'] is True):
                    jsonCFGetConfig['DistributionConfig']['Enabled'] = False
                    print(
                        "\t\tFirst Disabling the Cloud Front Distribution ( " +
                        cfDistItem['Id'] + " ) set enabled==" + str(
                            jsonCFGetConfig['DistributionConfig']['Enabled']))
                    cfDistFile = cfDistItem['Id'] + ".json"
                    deleteFile(cfDistFile)

                    with open(cfDistFile, 'a') as the_file:
                        the_file.write(
                            json.dumps(
                                jsonCFGetConfig['DistributionConfig'],
                                sort_keys=False,
                                indent=4))

                    disableCloudFront(cfDistItem['Id'],
                                      jsonCFGetConfig['ETag'], cfDistFile)

                    while (cfReadyToDelete is False):
                        deleteFile(filestatus)
                        getCloudFrontStatus(cfDistItem['Id'], filestatus)
                        valuesStatus = loadJsonFromFile(filestatus)
                        if (valuesStatus['Distribution']['Status'] ==
                                "InProgress"):
                            cfReadyToDelete = False
                            print(
                                "\t\t\tsleeping for 30 secs (POST Disabling) on ::"
                                + cfDistItem['Id'])
                            time.sleep(30)
                            print("\t\t\tAwake and checking on::" +
                                  cfDistItem['Id'])
                        else:
                            cfReadyToDelete = True

                    retval = deleteCloudFront(cfDistItem['Id'],
                                              jsonCFGetConfig['ETag'])

                else:
                    while (cfReadyToDelete is False):
                        try:
                            os.remove(filestatus)
                        except OSError:
                            pass

                        getCloudFrontStatus(cfDistItem['Id'], filestatus)
                        valuesStatus = loadJsonFromFile(filestatus)
                        if (valuesStatus['Distribution']['Status'] ==
                                "InProgress"):
                            cfReadyToDelete = False
                            print(
                                "\t\tsleeping for 30 secs (WAITING To DELETE)::"
                                + cfDistItem['Id'])
                            time.sleep(30)
                            print("\t\tAwake and checking on::" +
                                  cfDistItem['Id'])
                        else:
                            cfReadyToDelete = True

                    retval = deleteCloudFront(cfDistItem['Id'],
                                              jsonCFGetConfig['ETag'])

    print("Completed deleting of CF Distributions for stack {0}".format(
        stackname))
