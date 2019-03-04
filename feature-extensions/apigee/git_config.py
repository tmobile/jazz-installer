import subprocess
import urllib
import re
# TODO drop this whole script once we have API-based config implemented


def replace_config(apigeeHost, apigeeCredId, apigeeProdEnv, apigeeDevEnv,
                   apigeeSvcProdHost, apigeeSvcDevHost, apigeeOrg, repo,
                   username, password, pathext='/'):

    configFile = "jazz-installer-vars.json"
    buildFolder = './jazz-build-module/'

    filedata = fetch_configjson(repo, username, password, pathext, configFile, buildFolder)

    # Replace the target string
    filedata = filedata.replace('"{ENABLE_APIGEE}"', 'true')
    # To Do Store the crendential in Jenkins as apigeeCredId with apigee username and password
    filedata = filedata.replace('{APIGEE_CREDS}', apigeeCredId)
    filedata = filedata.replace('{MGMT_ORG}', apigeeOrg)
    filedata = filedata.replace('{MGMT_ENV_PROD}', apigeeProdEnv)
    filedata = filedata.replace('{MGMT_ENV_DEV}', apigeeDevEnv)
    filedata = filedata.replace('{MGMT_HOST}', apigeeHost)
    filedata = filedata.replace('{SVC_PROD_HOST}', apigeeSvcProdHost)
    filedata = filedata.replace('{SVC_DEV_HOST}', apigeeSvcDevHost)
    # TODO add more

    push_configjson(filedata, buildFolder, configFile, "'Adding Apigee feature'")


def fetch_configjson(repo, username, password, pathext, configFile, buildFolder):
    # Clone the SCM
    subprocess.check_call(
        [
            "git",
            "clone",
            ("http://%s:%s@%s%s/slf/jazz-build-module.git") %
            (username,
             urllib.quote(
                 password),
             repo,
             pathext),
            "--depth",
            "1"])

    # Read in the file
    with open(buildFolder+configFile, 'r') as file:
        filedata = file.read()

    return filedata


def push_configjson(filedata, buildFolder, configFile, message):
    # Write the file out again
    with open(buildFolder+configFile, 'w') as file:
        file.write(filedata)
    # Commit the changes
    subprocess.check_call(["git", "add", configFile], cwd=buildFolder)
    subprocess.check_call(["git", "commit", "-m", message], cwd=buildFolder)
    subprocess.check_call(["git", "push", "-u", "origin", "master"], cwd=buildFolder)
    subprocess.check_call(["rm", "-rf", buildFolder])


# For Uninstall
def revert_config(repo, username, password, pathext='/'):
    configFile = "jazz-installer-vars.json"
    buildFolder = './jazz-build-module/'
    filedata = fetch_configjson(repo, username, password, pathext, configFile, buildFolder)
    filedata = re.sub('("ENABLE_APIGEE":)(.*)', '"ENABLE_APIGEE": false,', filedata)
    push_configjson(filedata, buildFolder, configFile, "'Removing Apigee feature'")
