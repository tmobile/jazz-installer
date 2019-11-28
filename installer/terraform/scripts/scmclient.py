import json
import sys
import requests
from requests.auth import HTTPBasicAuth


def create_project(url, content, basic_auth):
    try:
        resp = requests.post(url,
                             data=json.dumps(content),
                             headers={"Content-Type": "application/json"},
                             auth=basic_auth)
        if resp.status_code != 201:
            print(resp.content)
            return False
    except Exception as e:
        raise Exception(str(e))


if __name__ == u"__main__":
    username = sys.argv[1]
    password = sys.argv[2]
    content_slf = {'key': 'SLF', 'name': 'SLF', 'description': 'To manage Core platform services'}
    content_cas = {'key': 'CAS', 'name': 'CAS', 'description': 'To manage User services'}
    url = 'http://' + sys.argv[3].strip("/") + '/rest/api/1.0/projects'
    basic_auth = HTTPBasicAuth(username, password)
    create_project(url, content_slf, basic_auth)
    create_project(url, content_cas, basic_auth)
