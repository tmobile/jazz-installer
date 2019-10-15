import time


def listCFDistributions():
    return cf_client.list_distributions()


def checkCloudFrontExists(CFId):
    try:
        return cf_client.get_distribution_config(Id=CFId)
    except Exception:
        return False


def getCloudFrontStatus(CFId):
    try:
        return cf_client.get_distribution(Id=CFId)
    except Exception:
        return False


def deleteCloudFront(CFId, eTAG):
    print("\tcalling delete of CloudFront Dist ( " + CFId + " )")
    try:
        cf_client.delete_distribution(Id=CFId, IfMatch=eTAG)
        print("\t\tSuccessfully deleted CloudFront Distribution ( " + CFId +
              " )")
    except Exception:
        print("\t\tError deleting CloudFront Distribution ( " + CFId + " )")


def disableCloudFront(CFId, eTAG, dconfig):
    try:
        return cf_client.update_distribution(Id=CFId, DistributionConfig=dconfig, IfMatch=eTAG)
    except Exception:
        return False


def delete_cf_dists(stackname, client, deletedists=False):
    global cf_client
    cf_client = client

    print("Fetching Cloud Front Distributions")

    jsonCFDists = listCFDistributions()

    print("Done Fetching Cloud Front Distributions.")

    # First disable all the active Cloud Fronts             #
    print("Starting disable of CF Distributions for stack: {0}".format(
        stackname))

    for cfDistItem in jsonCFDists['DistributionList']['Items']:
        if (cfDistItem['Origins']['Items'][0]['Id'].startswith(stackname)):

            cfGetConfigResp = checkCloudFrontExists(cfDistItem['Id'])
            cfReadyToDelete = False

            if (cfGetConfigResp is not False):
                jsonCFGetConfig = cfGetConfigResp

                if (jsonCFGetConfig['DistributionConfig']['Enabled'] is True):
                    jsonCFGetConfig['DistributionConfig']['Enabled'] = False
                    print("Found Stack CF Distribution  ( " +
                          cfDistItem['Id'] + " ) that needs to be disabled")
                    retval = disableCloudFront(cfDistItem['Id'],
                                               jsonCFGetConfig['ETag'],
                                               jsonCFGetConfig['DistributionConfig'])
                    if (retval is not False):
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

    for cfDistItem in jsonCFDists['DistributionList']['Items']:
        if (cfDistItem['Origins']['Items'][0]['Id'].startswith(stackname)):
            cfGetConfigResp = checkCloudFrontExists(cfDistItem['Id'])
            cfReadyToDelete = False

            if (cfGetConfigResp is not False):
                jsonCFGetConfig = cfGetConfigResp
                print("\tStarted on CloudFront Distribution ( " +
                      cfDistItem['Id'] + " ) which is enabled==" +
                      str(jsonCFGetConfig['DistributionConfig']['Enabled']))
                if (jsonCFGetConfig['DistributionConfig']['Enabled'] is True):
                    jsonCFGetConfig['DistributionConfig']['Enabled'] = False
                    print(
                        "\t\tFirst Disabling the Cloud Front Distribution ( " +
                        cfDistItem['Id'] + " ) set enabled==" + str(
                            jsonCFGetConfig['DistributionConfig']['Enabled']))
                    disableCloudFront(cfDistItem['Id'],
                                      jsonCFGetConfig['ETag'], jsonCFGetConfig['DistributionConfig'])

                    while (cfReadyToDelete is False):
                        valuesStatus = getCloudFrontStatus(cfDistItem['Id'])
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

                    deleteCloudFront(cfDistItem['Id'], jsonCFGetConfig['ETag'])

                else:
                    while (cfReadyToDelete is False):
                        valuesStatus = getCloudFrontStatus(cfDistItem['Id'])
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

                    deleteCloudFront(cfDistItem['Id'], jsonCFGetConfig['ETag'])

    print("Completed deleting of CF Distributions for stack {0}".format(
        stackname))
