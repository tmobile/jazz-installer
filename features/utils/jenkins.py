import requests
import subprocess


def setCredential(url, username, password,  credential_id, key, value, credfile="userpass_cred.sh"):
    downloadjenkinsJar(url)
    jenkins_cli_command = "java -jar jenkins-cli.jar -auth %s:%s -s  http://%s" % (
                          username, password, url)
    subprocess.check_call(
        [
            "bash",
            "utils/"+credfile,
            "%s" % (jenkins_cli_command),
            credential_id,
            key,
            value
            ])


def startJob(url, username, password, jobUrl):
    subprocess.check_call(
        [
            "curl",
            "-X",
            "POST",
            ("http://%s:%s@%s/%s") %
            (username, password, url, jobUrl),
        ])


def startJobwithInputs(url, username, password, job, input):
    downloadjenkinsJar(url)
    jenkins_build_command = \
        ' java -jar jenkins-cli.jar -s http://%s '\
        '-auth %s:%s build %s -p input=%s' \
        % (url, username, password, job, input)

    subprocess.call(jenkins_build_command, shell=True)


def downloadjenkinsJar(url):
    response = requests.get("http://%s/jnlpJars/jenkins-cli.jar" % (url))
    with open("jenkins-cli.jar", "wb") as file:
        file.write(response.content)
