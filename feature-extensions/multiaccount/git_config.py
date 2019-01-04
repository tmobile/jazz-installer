import subprocess
import urllib
import json
# TODO drop this whole script once we have API-based config implemented


def replace_config(account_json, repo, username, password, pathext='/'):

    configFile = "jazz-installer-vars.json"
    buildFolder = './jazz-build-module/'

    filedata = fetch_configjson(repo, username, password, pathext, configFile, buildFolder)
    installer_jsondata = json.loads(filedata)
    installer_jsondata['AWS']['ACCOUNTS'].append(account_json)
    push_configjson(json.dumps(installer_jsondata, indent=4), buildFolder, configFile, "'Adding multiaccount feature'")


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
