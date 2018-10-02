# coding: utf-8
import sys
import requests
from datetime import date
from urlparse import urljoin
from bs4 import BeautifulSoup

endpoint = u"http://localhost"
root_route = urljoin(endpoint, u"/")
sign_in_route = urljoin(endpoint, u"/users/sign_in")
pat_route = urljoin(endpoint, u"/profile/personal_access_tokens")


def find_csrf_token(text):
    soup = BeautifulSoup(text, u"lxml")
    token = soup.find(attrs={u"name": u"csrf-token"})
    param = soup.find(attrs={u"name": u"csrf-param"})
    data = {param.get(u"content"): token.get(u"content")}
    return data


def obtain_csrf_token():
    r = requests.get(root_route)
    token = find_csrf_token(r.text)
    return token, r.cookies


def sign_in(login, password, csrf, cookies):
    data = {
        u"user[login]": login,
        u"user[password]": password,
        u"user[remember_me]": 0,
        u"utf8": u"✓"
    }
    data.update(csrf)
    r = requests.post(sign_in_route, data=data, cookies=cookies)
    token = find_csrf_token(r.text)
    return token, r.history[0].cookies


def obtain_personal_access_token(name, csrf, cookies):
    today = date.today()
    data = {
        u"personal_access_token[expires_at]": today.replace(year=today.year + 1),
        u"personal_access_token[name]": name,
        u"personal_access_token[scopes][]": u"api",
        u"utf8": u"✓"
    }
    data.update(csrf)
    r = requests.post(pat_route, data=data, cookies=cookies)
    soup = BeautifulSoup(r.text, u"lxml")
    token = soup.find(
        u'input', id=u'created-personal-access-token').get('value')
    return token


def main():
    login = u"root"
    password = sys.argv[2]

    csrf1, cookies1 = obtain_csrf_token()
    csrf2, cookies2 = sign_in(login, password, csrf1, cookies1)

    name = sys.argv[1]
    token = obtain_personal_access_token(name, csrf2, cookies2)
    f = open("credentials.txt", "a")
    f.write("Private Token: %s" % token)
    f.close()


if __name__ == u"__main__":
    main()
