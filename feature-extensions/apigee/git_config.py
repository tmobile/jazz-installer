import subprocess
import urllib
# TODO drop this whole script once we have API-based config implemented


def replace_config(apigeeHost, apigeeCredId, apigeeEnv, apigeeOrg, repo, username, password, pathext):
    if not repo:
        repo = raw_input("Please enter the SCM Repo: ")

    if not username:
        username = raw_input("Please enter the SCM Username: ")

    if not password:
        password = raw_input("Please enter the SCM Password: ")

    if not pathext:
        pathext = raw_input("Please enter the Splunk Pathext (Use \"/scm\" for bitbucket): ") or "/"

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

    configFile = "jazz-installer-vars.json"
    buildFolder = './jazz-build-module/'
    # Read in the file
    with open(buildFolder+configFile, 'r') as file:
        filedata = file.read()

    # Replace the target string
    filedata = filedata.replace('"{ENABLE_APIGEE}"', 'true')
    # TODO add more

    # Write the file out again
    with open(buildFolder+configFile, 'w') as file:
        file.write(filedata)

    # Commit the changes
    subprocess.check_call(["git", "add", configFile], cwd=buildFolder)
    subprocess.check_call(["git", "commit", "-m", "'Adding Apigee feature'"], cwd=buildFolder)
    subprocess.check_call(["git", "push", "-u", "origin", "master"], cwd=buildFolder)
    subprocess.check_call(["rm", "-rf", buildFolder])
