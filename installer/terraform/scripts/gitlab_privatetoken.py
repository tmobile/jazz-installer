import requests
from datetime import date
from urllib.parse import urljoin
from bs4 import BeautifulSoup


def find_csrf_token(text):
    soup = BeautifulSoup(text, "lxml")
    token = soup.find(attrs={"name": "csrf-token"})
    param = soup.find(attrs={"name": "csrf-param"})
    data = {param.get("content"): token.get("content")}
    return data


def obtain_csrf_token(url):
    r = requests.get(url)
    token = find_csrf_token(r.text)
    return token, r.cookies


def sign_in(sign_in_url, login, password, csrf, cookies):
    data = {
        "user[login]": login,
        "user[password]": password,
        "user[remember_me]": 0,
        "utf8": "✓"
    }
    data.update(csrf)
    r = requests.post(sign_in_url, data=data, cookies=cookies)
    token = find_csrf_token(r.text)
    return token, r.history[0].cookies


def obtain_personal_access_token(pat_url, name, csrf, cookies):
    today = date.today()
    data = {
        "personal_access_token[expires_at]": today.replace(year=today.year + 1),
        "personal_access_token[name]": name,
        "personal_access_token[scopes][]": "api",
        "utf8": "✓"
    }
    data.update(csrf)
    r = requests.post(pat_url, data=data, cookies=cookies)
    soup = BeautifulSoup(r.text, u"lxml")
    token = soup.find(
        'input', id='created-personal-access-token').get('value')
    return token


def generate_personal_access_token(name, password, endpoint):
    login = "root"

    URL = 'http://{0}'.format(endpoint)
    SIGN_IN_URL = urljoin(URL, "/users/sign_in")
    PAT_URL = urljoin(URL, "/profile/personal_access_tokens")

    csrf1, cookies1 = obtain_csrf_token(URL)
    csrf2, cookies2 = sign_in(SIGN_IN_URL, login, password, csrf1, cookies1)

    return obtain_personal_access_token(PAT_URL, name, csrf2, cookies2)
