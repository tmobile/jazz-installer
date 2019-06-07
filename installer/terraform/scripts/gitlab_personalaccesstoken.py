import sys
import requests
import bs4
from urllib.parse import urljoin
from datetime import date


def get_authenticity_token(response_text, form_id):
    root = bs4.BeautifulSoup(response_text, "html5lib")
    token = root.find_all(
        "form",
        id=form_id)[0].find_all('input', attrs={'name': 'authenticity_token'})[0]['value']

    if not token:
        print('Unable to find the authenticity token')
        sys.exit(1)

    return token


def get_personal_access_token(response_text):
    personal_token_page = bs4.BeautifulSoup(response_text, "html5lib")
    personal_token = personal_token_page.find_all('input', id='created-personal-access-token')[0]['value']

    if not personal_token:
        print('Unable to find personal access token')
        sys.exit(1)

    return personal_token


def generate_personal_access_token(name, password, endpoint):
    """
        Adapted from: https://gist.github.com/gpocentek/bd4c3fbf8a6ce226ebddc4aad6b46c0a
        Uses authenticity tokens and bs4+html5lib to log into the Gitlab web interface
        and generate a personal access token for API usage
        Assumes initial password has been set for "root" user
    """
    URL = 'http://{0}'.format(endpoint)
    SIGN_IN_URL = urljoin(URL, "/users/sign_in")
    PAT_URL = urljoin(URL, "/profile/personal_access_tokens")

    session = requests.Session()

    sign_in_page = session.get(SIGN_IN_URL)
    sign_in_page.raise_for_status()
    token = get_authenticity_token(sign_in_page.text, 'new_user')

    data = {'user[login]': 'root',
            'user[password]': '{0}'.format(password),
            'authenticity_token': token}
    r = session.post(SIGN_IN_URL, data=data)
    r.raise_for_status()

    page_tokens = session.get(PAT_URL)
    page_tokens.raise_for_status()

    token = get_authenticity_token(page_tokens.text, 'new_personal_access_token')

    today = date.today()
    body = {
        "personal_access_token[name]": name,
        "personal_access_token[expires_at]": today.replace(year=today.year + 1),
        "personal_access_token[scopes][]": 'api',
        'authenticity_token': token
    }

    response = session.post(PAT_URL, data=body)
    response.raise_for_status

    return get_personal_access_token(response.text)
