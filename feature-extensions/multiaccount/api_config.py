import requests
import json


def update_config(key, value, username, password, endpoint):
    token = obtain_token(username, password, endpoint)
    config_data = {}
    config_data[key] = value
    requests.post(endpoint+'/jazz/admin/config', data=json.dumps(config_data),
                  headers={"Content-Type": "application/json", "Authorization": "%s" % (token)})


def get_config(username, password, endpoint):
    token = obtain_token(username, password, endpoint)
    response = requests.get(endpoint+'/jazz/admin/config',
                            headers={"Content-Type": "application/json", "Authorization": "%s" % (token)})

    return json.loads(response.content)


def obtain_token(username, password, endpoint):
    data = '{"username":"%s","password":"%s"}' % (username, password)
    response = requests.post(endpoint+'/jazz/login', data=data, headers={"Content-Type": "application/json"})
    auth_response = json.loads(response.content)

    return auth_response['data']['token']


def update_config_in(key, value, username, password, endpoint, query_url):
    token = obtain_token(username, password, endpoint)
    config_data = {}
    config_data[key] = value
    requests.post(endpoint+'/jazz/admin/config'+query_url, data=json.dumps(config_data),
                  headers={"Content-Type": "application/json", "Authorization": "%s" % (token)})
