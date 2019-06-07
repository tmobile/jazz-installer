import requests
from requests.auth import HTTPBasicAuth
import sys
import time


def updateSonar(url, post_data, password='admin', max_retry=5):
    username = 'admin'
    response = requests.post("http://"+url, auth=HTTPBasicAuth(username, password), data=post_data)
    if response.status_code != 200 and response.status_code != 204 and max_retry > 0:
        max_retry -= 1
        time.sleep(60)
        updateSonar(url, post_data, password, max_retry)


if __name__ == u"__main__":
    updateSonar(sys.argv[1]+"/api/qualityprofiles/create", {"name": "JazzProfile", "language": "java"})
    updateSonar(sys.argv[1]+"/api/qualityprofiles/create", {"name": "JazzProfile", "language": "js"})
    updateSonar(sys.argv[1]+"/api/qualityprofiles/create", {"name": "JazzProfile", "language": "py"})
    updateSonar(sys.argv[1]+"/api/users/change_password", {"login": "admin", "password": sys.argv[2],
                "previousPassword": "admin"})
    time.sleep(10)
    updateSonar(sys.argv[1]+"/api/system/restart", {}, sys.argv[2])
