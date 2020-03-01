#!/usr/bin/env python3
"""
Univention can be set globally to expire passwords.

As this is not best practice anymore and remembering a new password is cumbersome, this script
allows to reset your paswword.
The script will generate and set 10 random passwords, after it will reset the password
to the original.
"""

import sys
import json
import getpass
import string
import random
import requests
import mechanicalsoup

from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


LOGIN_URL = 'https://univention.eu.idealo.com/univention/auth'
CHANGE_REQUEST_URL = 'https://univention.eu.idealo.com/univention/set'


def error_api_call(answer):
    """Quit the script with error message"""
    decoded_answer = answer.decode("utf-8")
    message = json.loads(decoded_answer).get('message', 'No error message')
    print(message)
    sys.exit(1)

def set_password(user_to_change, old_password, new_password, dryrun=False):
    login_payload = {
        "options":{
            "username": user_to_change,
            "password": old_password
        }
    }

    password_change_payload = {
        "options":{
            "password":{
                "username": user_to_change,
                "password": old_password,
                "new_password": new_password
            }
        }
    }
    if not dryrun:
        browser = \
            mechanicalsoup.Browser(user_agent='Python univention password changer')
        answer = browser.post(LOGIN_URL, json=login_payload, verify=False)
        if answer.ok is not True:
            error_api_call(answer.content)
        session_id = browser.session.cookies.get('UMCSessionId')
        browser.session.headers.update({'X-XSRF-Protection': session_id})
        answer = browser.post(CHANGE_REQUEST_URL,
                              json=password_change_payload,
                              verify=False)
        if answer.ok is not True:
            error_api_call(answer.content)



def main():
    """Executed when the script is called directly"""
    user_to_change = input("Username: ")
    password = getpass.getpass('Password: ')

    old_password = password
    for count in range(1, 10):
        letters = ''.join(random.choices(string.ascii_letters, k=10))
        digits = ''.join(random.choices(string.digits, k=2))
        punctuation = ''.join(random.choices(string.punctuation, k=2))
        new_password = letters + digits + punctuation
        print("setting new password ({}/10): {}".format(count, new_password))
        set_password(user_to_change, old_password, new_password)
        old_password = new_password
        print(" success")

    print("Resetting Password to original")
    set_password(user_to_change, old_password, password)
    print(" success")


if __name__ == '__main__':
    main()
