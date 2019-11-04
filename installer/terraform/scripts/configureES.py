import requests
import json
import sys


def create_index(key, endpoint):
    with open("./jazz-core/core/jazz_es-kinesis-log-streamer/_ES/%s.json" % key) as json_file:
        config_data = json.load(json_file)
        requests.post("%s/_template/%s" % (endpoint, key), data=json.dumps(config_data),
                      headers={"Content-Type": "application/json"})
        requests.put("%s/%s?pretty" % (endpoint, key), data=json.dumps(config_data),
                     headers={"Content-Type": "application/json"})


def create_index_pattern(key, endpoint):
    index_pattern_logs = "%s/api/saved_objects/index-pattern/%s" % (endpoint, key)
    config_data = {"attributes": {"title": key, "timeFieldName": "timestamp"}}
    requests.post(index_pattern_logs, data=json.dumps(config_data),
                  headers={"Content-Type": "application/json", "kbn-xsrf": "true"})


def change_def_index(key, endpoint):
    index_pattern_logs = "%s/api/kibana/settings" % endpoint
    config_data = {"changes": {"defaultIndex": key}}
    requests.post(index_pattern_logs, data=json.dumps(config_data),
                  headers={"Content-Type": "application/json", "kbn-xsrf": "true"})


if __name__ == '__main__':
    es_endpoint = sys.argv[1]
    kibana_endpoint = sys.argv[2]
    for item in ["apilogs", "applicationlogs"]:
        create_index(item, es_endpoint)
        create_index_pattern(item, kibana_endpoint)
    change_def_index("applicationlogs", kibana_endpoint)
