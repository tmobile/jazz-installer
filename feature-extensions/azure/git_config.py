import subprocess
import urllib


# TODO drop this whole script once we have API-based config implemented

def clone_git_config_repo(repo, username, password, pathext, folder):
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
            "1",
            folder])


def commit_git_config(buildFolder, configFile, message):
    subprocess.check_call(["git", "add", configFile], cwd=buildFolder)
    subprocess.check_call(["git", "commit", "-m", "'{}'".format(message)], cwd=buildFolder)
    subprocess.check_call(["git", "push", "-u", "origin", "master"], cwd=buildFolder)
    subprocess.check_call(["rm", "-rf", buildFolder])
