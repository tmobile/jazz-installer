import argparse
import sys
sys.path.append('../config')  # noqa: E402
from api_config import update_config


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


featureName = "Splunk"


def main():
    mainParser = argparse.ArgumentParser()
    mainParser.description = ('Installs the Splunk extension for the Jazz Serverless Development Platform '
                              '(https://github.com/tmobile/jazz)')
    subparsers = mainParser.add_subparsers(help='Installation scenarios', dest='command')

    subparsers.add_parser('install', help='Install feature extension').set_defaults(func=install)

    mainParser.add_argument(
        '--splunk-endpoint',
        help='Specify the splunk endpoint'
    )
    mainParser.add_argument(
        '--splunk-token',
        help='Specify the splunk token'
    )
    mainParser.add_argument(
        '--splunk-index',
        help='Specify the splunk index'
    )
    mainParser.add_argument(
        '--jazz-username',
        help='Specify the Jazz username'
    )

    mainParser.add_argument(
        '--jazz-password',
        help='Specify the Jazz password'
    )

    mainParser.add_argument(
        '--jazz-apiendpoint',
        help='Specify the Jazz password'
    )

    args = mainParser.parse_args()
    args.func(args)


def install(args):
    print(
        colors.OKGREEN +
        "\nThis will install {0} functionality into your Jazz deployment.\n".format(featureName)
        + colors.ENDC)

    configureSplunk(args, True)


def configureSplunk(args, splunk_enable):

    if not args.splunk_endpoint:
        args.splunk_endpoint = raw_input("Please enter the Splunk Endpoint: ")

    if not args.splunk_token:
        args.splunk_token = raw_input("Please enter the Splunk Token: ")

    if not args.splunk_index:
        args.splunk_index = raw_input("Please enter the Splunk Index: ")

    if not args.jazz_username:
        args.jazz_username = raw_input("Please enter the Jazz Admin Username: ")

    if not args.jazz_password:
        args.jazz_password = raw_input("Please enter the Jazz Admin Password: ")

    if not args.jazz_apiendpoint:
        args.jazz_apiendpoint = raw_input("Please enter the Jazz API Endpoint(Full URL): ")

    if not args.splunk_endpoint and not args.splunk_token and not args.splunk_index:
        print(colors.FAIL +
              'Cannot proceed! No install possible'
              + colors.ENDC)
        return True

    splunk_json = prepare_splunk_json(args)
    update_config(
        "SPLUNK",
        splunk_json,
        args.jazz_username,
        args.jazz_password,
        args.jazz_apiendpoint
    )


def prepare_splunk_json(args):
    splunk_json = {
        "ENDPOINT": args.splunk_endpoint,
        "HEC_TOKEN": args.splunk_token,
        "INDEX": args.splunk_index,
        "IS_ENABLED": True
    }
    return splunk_json


main()
