#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import requests
import datetime
import os
import base64
import sqlite3

db = sqlite3.connect('database.db')
c = db.cursor()
c.execute("""SELECT id, key FROM passkeys WHERE id=1""")
key = c.fetchone()
db.close()

def decode(key, enc):
    dec = []
    enc = base64.urlsafe_b64decode(enc).decode()
    for i in range(len(enc)):
        key_c = key[i % len(key)]
        dec_c = chr((256 + ord(enc[i]) - ord(key_c)) % 256)
        dec.append(dec_c)
    return "".join(dec)

# Authentication for user filing issue (must have read/write access to
# repository to add issue to)
USERNAME = 'stillbirthbugreports'
PASSWORD = decode(key, 'YMOrwqvCn8KhwqHCmsOKw5jDmsKh')

# The repository to add this issue to
REPO_OWNER = 'Shisheyu'
REPO_NAME = 'AfterBrasse'

def make_github_issue(title, body=None, assignee=None, milestone=None, labels=None):
    '''Create an issue on github.com using the given parameters.'''
    # Our url to create issues via POST
    url = 'https://api.github.com/repos/%s/%s/issues' % (REPO_OWNER, REPO_NAME)
    # Create an authenticated session to create the issue
    session = requests.Session()
	session.auth = (USERNAME, PASSWORD)
    # Create our issue
    issue = {'title': title,
             'body': body,
             'assignee': assignee,
             'milestone': milestone,
             'labels': labels}
    # Add the issue to our repository
    r = session.post(url, json.dumps(issue))
    if r.status_code == 201:
        print('Successfully created Issue "%s"' % title)
    else:
        print('Could not create Issue "%s"' % title)
        print('Response:', r.content)


def get_log():
	path = "../../binding of isaac afterbirth+/log.txt"
	date = datetime.datetime.now.strftime("%Y-%m-%d %H:%M")
	name = os.getenv('COMPUTERNAME')
	t = "Bug Report of " + name + " at " + date
	b = "```\n"
	with open(path, "r") as f:
		b += f.readlines()
	b += "\n```"
	make_github_issue(t, body = b, labels=['bug'])
	pass
	
if __name__ == "__main__":
	get_log()
	pass

