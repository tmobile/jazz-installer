#!/usr/bin/python
import base64
import hmac
import hashlib
import sys
import os

SMTP_FILE = 'smtppassword.txt'

if(len(sys.argv) != 2):
    print ("Error - Please provide secret key")
    exit(1)

secret = sys.argv[1] # # replace with the secret key to be hashed
#get the aws Secret key 
print "aws_secret:" + secret

if os.path.isfile(SMTP_FILE):
	os.remove(SMTP_FILE)
	
def get_ses_smtp_password(secret):
	#Generate the SES SMTP password	
	message = "SendRawEmail"
	sig_bytes = bytearray(b'\x02')  # init with version

	theHmac = hmac.new(secret.encode("ASCII"), message.encode("ASCII"), hashlib.sha256)
	the_hmac_hexdigest = theHmac.hexdigest()
	sig_bytes.extend(bytearray.fromhex(the_hmac_hexdigest))
	retstr = base64.b64encode(sig_bytes).decode('ascii')
	return retstr

ses_smtp_password = get_ses_smtp_password(secret)
print "ses_smtp_password:" + ses_smtp_password

f = open(SMTP_FILE, 'w')
f.write(ses_smtp_password)  # python will convert \n to os.linesep
f.close() 
