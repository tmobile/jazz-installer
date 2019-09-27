import requests
import subprocess
import sys
from requests.auth import HTTPBasicAuth
from utils.helper import colors


def setCredential(jenkins_url, jenkins_user, jenkins_api_token, credential_id, key, value, credtype="userpass"):
    basic_auth = HTTPBasicAuth(jenkins_user, jenkins_api_token)
    url = "http://{}/credentials/store/system/domain/_/createCredentials".format(jenkins_url)
    if credtype == "userpass":
        content = ("{{\n"
                   "  \"\": \"0\",\n"
                   "  \"credentials\": {{\n"
                   "    \"scope\": \"GLOBAL\",\n"
                   "    \"id\": \"{0}\",\n"
                   "    \"username\": \"{1}\",\n"
                   "    \"password\": \"{2}\",\n"
                   "    \"description\": \"{0}\",\n"
                   "    \"$class\": \"com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl\"\n"
                   "  }}\n"
                   "}}").format(credential_id, key, value)
    if credtype == "aws":
        content = ("{{\n"
                   "  \"\": \"0\",\n"
                   "  \"credentials\": {{\n"
                   "    \"scope\": \"GLOBAL\",\n"
                   "    \"id\": \"{0}\",\n"
                   "    \"accessKey\": \"{1}\",\n"
                   "    \"secretKey\": \"{2}\",\n"
                   "    \"description\": \"{0}\",\n"
                   "    \"iamRoleArn\": \"\",\n"
                   "    \"iamMfaSerialNumber\": \"\",\n"
                   "    \"$class\": \"com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl\"\n"
                   "  }}\n"
                   "}}").format(credential_id, key, value)
    data = {'json': content}
    resp = requests.post(url, data=data, auth=basic_auth)
    if resp.status_code != 200:
        print(colors.FAIL +
              "Failed to add {0} credential to jenkins. Response code: {1}".format(key, resp.status_code)
              + colors.ENDC)
        sys.exit(1)


def deleteCredential(jenkins_url, jenkins_user, jenkins_api_token, credid):
    basic_auth = HTTPBasicAuth(jenkins_user, jenkins_api_token)
    url = "http://{}/credentials/store/system/domain/_/credential/{}/doDelete".format(jenkins_url, credid)
    resp = requests.post(url, auth=basic_auth)
    if resp.status_code != 200:
        print("Failed to delete credential from jenkins.")
        sys.exit(1)


def startJob(url, username, password, jobUrl):
    requests.post(("http://%s:%s@%s/%s") % (username, password, url, jobUrl))


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
