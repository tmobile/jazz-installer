import click

from utils.api_config import update_config


featureName = "Splunk"


@click.command()
@click.option(
    "--splunk_endpoint",
    help=('Specify the splunk endpoint'),
    required=True,
    prompt=True
)
@click.option(
    "--splunk_token",
    help=('Specify the splunk token'),
    required=True,
    prompt=True
)
@click.option(
    "--splunk_index",
    help=('Specify the splunk index'),
    required=True,
    prompt=True
)
@click.option(
    "--jazz_apiendpoint",
    help='Specify the Jazz Endpoint',
    prompt=True
)
@click.option(
    '--jazz_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the jazz application separated by a space',
    prompt=True
)
def install(splunk_endpoint, splunk_token, splunk_index, jazz_apiendpoint, jazz_userpass):
    click.secho('\n\nThis will install {0} functionality into your Jazz deployment'.format(featureName), fg='blue')
    jazz_userpass_list = ''.join(list(jazz_userpass)).split()
    jazz_username, jazz_password = jazz_userpass_list[0], jazz_userpass_list[1]
    splunk_json = prepare_splunk_json(splunk_endpoint, splunk_token, splunk_index)
    update_config(
        "SPLUNK",
        splunk_json,
        jazz_username,
        jazz_password,
        jazz_apiendpoint
    )


def prepare_splunk_json(splunk_endpoint, splunk_token, splunk_index):
    splunk_json = {
        "ENDPOINT": splunk_endpoint,
        "HEC_TOKEN": splunk_token,
        "INDEX": splunk_index,
        "IS_ENABLED": True
    }
    return splunk_json
