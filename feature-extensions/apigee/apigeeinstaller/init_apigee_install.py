import base64
import json
import mimetools
import os
import re
from urllib2 import Request, HTTPError, URLError, urlopen
from zipfile import ZipFile


def print_banner(message):
    print ("**************************************************")
    print (message)
    print ("**************************************************")


# TODO do we really want to rely only on basic auth for admin access to external Apigee?
def get_basic_auth(username, password):
    up = '%s:%s' % (username, password)
    return "Basic %s" % base64.b64encode(up).decode()


def create_kvm(secretKey, accessKey, region, lambdaARN, host, org, env, username, password):
    print_banner("Creating the KVM for Common-Jazz API Proxy .......")
    payload = {
        "encrypted": "true",
        "entry": [
            {
                "name": "accessKey",
                "value": accessKey
            },
            {
                "name": "secretKey",
                "value": secretKey
            },
            {
                "name": "reg",
                "value": region
            },
            {
                "name": "lambdaARN",
                "value": lambdaARN
            }
        ],
        "name": "jzencryptedLambdaMaps"
    }
    data = json.dumps(payload).encode('utf-8')
    headers = {
        'Content-Type': 'application/json',
        'Authorization': get_basic_auth(username, password)
    }
    url = "%s/v1/o/%s/e/%s/keyvaluemaps" % (host, org, env)

    req = Request(url, data, headers)
    try:
        res = urlopen(req)
        if res.getcode() == 201:
            print_banner("KVM created successfully for the Common-Jazz API Proxy")
        else:
            print_banner("KVM creation FAILED for the Common-Jazz API Proxy")
    except HTTPError, e:
        print "HTTP Error:", e.code
        print_banner("KVM already present for the Common-Jazz API Proxy")
        pass


def get_current_deployed_version(host, org, env, flow, username, password):
    print("Getting the current deployed version of %s in %s/%s on %s" % (flow, org, env, host))
    deployedVersion = ''
    try:
        url = "%s/v1/o/%s/sharedflows/%s/deployments" % (host, org, flow)
        req = Request(url)
        req.add_header('Authorization', get_basic_auth(username, password))
        req.add_header('Accept', 'application/json')
        res = urlopen(req)
        apis = json.load(res)
        for e in apis['environment']:
            if (e['name'] == env):
                deployedVersion = e['revision'][0]['name']
                break
        print("Deployed version: %s" % deployedVersion)
    except HTTPError, e:
        # To handle very first deployment
        print "HTTP Error:", e.code
    return deployedVersion


def is_api_deployed(host, org, env, name, revision, username, password):
    url = "%s/v1/o/%s/e/%s/apis/%s/revisions/%s/deployments" % (host, org, env, name, revision)
    req = Request(url)
    req.add_header('Authorization', get_basic_auth(username, password))
    req.add_header('Accept', 'application/json')
    res = urlopen(req)
    return res.getcode() == 200


def import_item(zFile, host, org, name, importType, username, password):
    url = "%s/v1/o/%s/%s?action=import&name=%s" % (host, org, importType, name)
    boundary = mimetools.choose_boundary()
    with open(zFile, 'rb') as fileHandle:
        fileContent = fileHandle.read()
    headers = {
        'Accept': 'application/json',
        'Authorization': get_basic_auth(username, password),
        'Content-Type': "multipart/form-data; boundary=%s" % boundary
    }
    data = (
        ("--%s\r\nContent-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n" +
            "Content-Type: application/x-zip-compressed\r\n\r\n%s\r\n--%s--")
        % (boundary, zFile, fileContent, boundary))
    req = Request(url, data, headers)
    res = urlopen(req)
    result = json.load(res)
    return result['revision']


def import_api(zFile, host, org, api, username, password):
    print("Importing new api proxy %s in %s on %s" % (api, org, host))
    apiRevision = import_item(zFile, host, org, api, 'apis', username, password)
    print("  New api proxy revision imported: %s" % apiRevision)
    return apiRevision


def import_bundle(zFile, host, org, flow, username, password):
    print("Importing new SharedFlowBundle %s in %s on %s" % (flow, org, host))
    bundleRevision = import_item(zFile, host, org, flow, 'sharedflows', username, password)
    print("  New revision imported: %s" % bundleRevision)
    return bundleRevision


def undeploy(host, org, env, flow, revision, username, password):
    print("Undeploying the current deployed version of %s in %s/%s on %s" % (flow, org, env, host))
    url = "%s/v1/o/%s/e/%s/sharedflows/%s/revisions/%s/deployments" % (host, org, env, flow, revision)
    req = Request(url, headers={'Authorization': get_basic_auth(username, password)})
    req.get_method = lambda: 'DELETE'
    res = urlopen(req)
    print(res.read())


def deploy(host, org, env, flow, revision, username, password):
    print("Deploying the revision %s of %s in %s/%s on %s" % (revision, flow, org, env, host))
    url = "%s/v1/o/%s/e/%s/sharedflows/%s/revisions/%s/deployments?override=true" % (host, org, env, flow, revision)
    req = Request(url, headers={'Authorization': get_basic_auth(username, password)})
    req.get_method = lambda: 'POST'
    res = urlopen(req)
    print(res.read())


def deploy_api(host, org, env, apiName, revision, username, password):
    print("Deploying the revision %s of %s in %s/%s on %s" % (revision, apiName, org, env, host))
    url = (
        "%s/v1/o/%s/apis/%s/revisions/%s/deployments?action=deploy&env=%s&override=true"
        % (host, org, apiName, revision, env))
    req = Request(url, headers={'Authorization': get_basic_auth(username, password)})
    req.get_method = lambda: 'POST'
    res = urlopen(req)
    print(res.read())
    return is_api_deployed(host, org, env, apiName, revision, username, password)


def stamp_build(path, item, build):
    flowFile = os.path.join(path, 'sharedflowbundle', "%s.xml" % item)
    with open(flowFile, 'r') as inFile:
        content = inFile.read()
    # flake8: noqa
    content = re.sub('(?<=\<Description\>).+(?=\</Description\>)', build, content)

    with open(flowFile, 'w') as outFile:
        outFile.write(content)

    print(item + ' stamped with build: ' + build)


def zip_bundle(path, name, build):
    zfPath = os.path.join(path, "%s-%s.zip" % (name, build))
    zf = ZipFile(zfPath, 'w')
    offset = len(path)
    for dir, dirList, fileList in os.walk(os.path.join(path, 'sharedflowbundle')):
        for addFile in fileList:
            sourcePath = os.path.join(dir, addFile)
            zf.write(sourcePath, sourcePath[offset:len(sourcePath)])
    zf.close()
    return zfPath


def deploy_shared_flows(host, org, env, build, username, password):
    print_banner("Deploying Sharedflows now ............")
    flowDir = "apigeeinstaller/sharedflows"
    for item in os.listdir(flowDir):
        itemPath = os.path.join(flowDir, item)
        if os.path.isdir(itemPath):
            stamp_build(itemPath, item, build)
            zfPath = zip_bundle(itemPath, item, build)
            deployedVersion = get_current_deployed_version(host, org, env, item, username, password)
            if deployedVersion:
                undeploy(host, org, env, item, deployedVersion, username, password)
            revision = import_bundle(zfPath, host, org, item, username, password)
            deploy(host, org, env, item, revision, username, password)
    print_banner("Sharedflows deployment Complete")


def get_content(fileName, baseUrl, branch):
    fullUrl = "%s/raw/%s/apigee/%s" % (baseUrl, branch, fileName)
    try:
        print("Downloading %s...." % fullUrl)
        req = urlopen(fullUrl)
        with open(os.path.basename(fileName), "wb") as local_file:
                local_file.write(req.read())
    except HTTPError, e:
        print "HTTP Error:", e.code, fullUrl
    except URLError, e:
        print "URL Error:", e.reason, fullUrl


def deploy_common(host, org, env, username, password, contentUrl, contentBranch):
    print_banner("Importing the Common-Jazz API Proxy ......")
    get_content('Common-Jazz.zip', contentUrl, contentBranch)
    commonRevision = import_api('Common-Jazz.zip', host, org, 'Common-Jazz', username, password)
    success = deploy_api(host, org, env, 'Common-Jazz', commonRevision, username, password)
    if success:
        print_banner("Common-Jazz deployed successfully")
    else:
        print_banner("Common-Jazz NOT deployed successfully")
    return success


def install_proxy(secretKey, accessKey, region, lambdaARN, host, org,
                  envProd, envDev, build, username, password,
                  contentUrl='https://github.com/tmobile/jazz-content', contentBranch='master'):
    """Configure the external Apigee proxy and upload shared flows.

    Keyword arguments:
    secretKey -- AWS user secret key
    accessKey -- AWS user access key
    region -- AWS Region
    lambdaARN -- ARN of the gateway function Apigee will invoke
    host -- Apigee host
    org -- Apigee org to apply this took
    username -- Apigee instance basic auth username
    password -- apigee instance basic auth password
    """
    for env in [envProd, envDev]:
        create_kvm(secretKey, accessKey, region, lambdaARN, host, org, env, username, password)
        deploy_shared_flows(host, org, env, build, username, password)
        deploy_common(host, org, env, username, password, contentUrl, contentBranch)
