from utils.api_config import get_config


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

    
def azure_installed(jazz_username, jazz_password, jazz_apiendpoint):
    get_configjson = get_config(jazz_username, jazz_password, jazz_apiendpoint)
    return 'AZURE' in get_configjson['data']['config']
