import sys
import requests
import json
from requests.auth import HTTPBasicAuth
from .common import get_tfvars_file, replace_tfvars


def check_bitbucket_user(url, username, passwd):
    """
        Check if the bitbucket user is present on the Bitbucket server
    """
    bitbucket_url = 'http://' + url + ''.strip("/")
    content = {'key': 'TEST', 'name': 'TEST', 'description': 'To manage Core platform services'}
    api_project_createurl = bitbucket_url + '/rest/api/1.0/projects'
    api_project_deleteurl = bitbucket_url + '/rest/api/1.0/projects/' + content['key']
    basic_auth = HTTPBasicAuth(username, passwd)
    try:
        resp = requests.post(api_project_createurl,
                             data=json.dumps(content),
                             headers={"Content-Type": "application/json"},
                             auth=basic_auth)
        if resp.status_code != 200:
            print(resp.content)
            return False
        else:
            requests.delete(api_project_deleteurl, auth=basic_auth)
            return True
    except:
        return False


def configure_bitbucket(bbelb, bbuserpass, bbip):
    # Check if the user provided bitbucket user exist
    if check_bitbucket_user(bbelb, bbuserpass[0], bbuserpass[1]):
        print(
            "Great! We can proceed with this Bitbucket user....We will need few more details of Bitbucket server"
        )
    else:
        sys.exit(
            "Kindly provide an 'Admin' Bitbucket user with correct password and run the installer again!"
        )
    replace_tfvars('scm_elb', bbelb, get_tfvars_file())
    replace_tfvars('scm_username', bbuserpass[0], get_tfvars_file())
    replace_tfvars('scm_passwd', bbuserpass[1], get_tfvars_file())
    replace_tfvars('scm_publicip', bbip, get_tfvars_file())
    replace_tfvars('scm_type', 'bitbucket', get_tfvars_file())
    replace_tfvars('scm_pathext', '/scm', get_tfvars_file())
