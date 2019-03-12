import requests
from requests.auth import HTTPBasicAuth
import sys
import time


def updateSonar(url, post_data, password='admin'):
    username = 'admin'
    requests.post("http://"+url, auth=HTTPBasicAuth(username, password), data=post_data)


if __name__ == u"__main__":
    updateSonar(sys.argv[1]+"/api/qualityprofiles/create", {"name": "JazzProfile", "language": "java"})
    updateSonar(sys.argv[1]+"/api/qualityprofiles/create", {"name": "JazzProfile", "language": "js"})
    updateSonar(sys.argv[1]+"/api/qualityprofiles/create", {"name": "JazzProfile", "language": "py"})
    updateSonar(sys.argv[1]+"/api/users/change_password", {"login": "admin", "password": sys.argv[2],
                "previousPassword": "admin"})
    time.sleep(10)
    updateSonar(sys.argv[1]+"/api/system/restart", {}, sys.argv[2])
