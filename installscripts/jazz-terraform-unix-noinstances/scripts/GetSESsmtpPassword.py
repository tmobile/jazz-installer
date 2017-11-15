#!/usr/bin/python
import base64
import hmac
import hashlib
import sys
import os

DEFAULT_RB_FILE = "../cookbooks/jenkins/attributes/default.rb"

if(len(sys.argv) != 2):
    print ("Error - Please provide secret key")
    exit(1)

secret = sys.argv[1] # # replace with the secret key to be hashed
#get the aws Secret key 
print "aws_secret:" + secret

def get_ses_smtp_password(secret):
	"""
		Method will generate SES SMTP password	. 
	"""
	message = "SendRawEmail"
	sig_bytes = bytearray(b'\x02')  # init with version

	theHmac = hmac.new(secret.encode("ASCII"), message.encode("ASCII"), hashlib.sha256)
	the_hmac_hexdigest = theHmac.hexdigest()
	sig_bytes.extend(bytearray.fromhex(the_hmac_hexdigest))
	retstr = base64.b64encode(sig_bytes).decode('ascii')
	return retstr

def write_ses_smtp_password_to_defaultrb(ses_smtp_password):	
	"""
		Method will change the 'smtpAuthPasswordValue' in file default.db
		present in the jenkins cookbook. 
	"""
	with open(DEFAULT_RB_FILE, 'r+') as fd:
		line = fd.read()
		
		if line.find('smtpAuthPasswordValue') > 0:
				line = line.replace('smtpAuthPasswordValue', ses_smtp_password)
		fd.seek(0)
		fd.write(line)
	fd.close()

ses_smtp_password = get_ses_smtp_password(secret)
print "ses_smtp_password:" + ses_smtp_password
write_ses_smtp_password_to_defaultrb(ses_smtp_password)


