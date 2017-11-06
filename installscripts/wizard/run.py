#!/usr/bin/python
from __future__ import print_function
import os
import sys
import subprocess
import datetime
import string
import random


def is_non_zero_file(fpath):
    return os.path.isfile(fpath) and os.path.getsize(fpath) > 0
def pause():
    programPause = raw_input("Press the <ENTER> key to continue...")
def update_destroy_script_with_cidr(fpath,cidr):
    with open(fpath,'r') as readhandler:
        originalText = readhandler.read()
        with open(fpath,'w') as writehandler:
            writehandler.write(originalText.replace('CIDRPLACEHOLDER',cidr))
			
#Random password generator for jazz-ui admin email ID login:			
def passwd_generator(size=9, chars=string.ascii_uppercase + string.ascii_letters + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))
	
tagEnvPrefix = raw_input("Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): ")
tagApplication="JAZZ"
tagEnvironment="Development"
tagExempt=(datetime.datetime.today()+datetime.timedelta(days=1)).strftime("%m/%d/%Y")
tagOwner=tagEnvPrefix+"-Admin"

print(" Please create the following adminid/password on Jenkins Server before you proceed: jenkinsadmin/jenkinsadmin")
print(" Please create the following adminid/password on Bitbucket Server before you proceed: jenkins1/jenkinsadmin")
print(" Please make sure that you have the ssh login user names of jenkins and bitbucket servers.")
print(" Please create jenkinskey.pem and bitbucketkey.pem with private keys of Jenkins and Bitbucket in /home/ec2-user")
pause()

jenkinsServerELB = raw_input("Please provide Jenkins URL (Please ignore http and port number from URL): ")
jenkinsServerPublicIp = raw_input("Please provide Jenkins Server PublicIp: ")
jenkinsServerSSHLogin = raw_input("Please provide Jenkins SSH login name: ")

bitBucketServerELB = raw_input("Please provide Bitbuckket URL (Please ignore http and port number from URL): ")
bitBucketServerPublicIp = raw_input("Please provide bitbucket Server PublicIp: ")
bitBucketServerSSHLogin = raw_input("Please provide bitbucket SSH login name: ")

subprocess.call('cp -f ../../../jenkinskey.pem ../sshkeys && sudo chmod 400 ../sshkeys/jenkinskey.pem', shell=True)
subprocess.call('cp -f ../../../bitbucketkey.pem ../sshkeys/ && sudo chmod 400 ../sshkeys/bitbucketkey.pem', shell=True)

	
os.chdir("../terraform-unix-networkstack")
cmd = ["./scripts/createServerVars.sh", jenkinsServerELB, jenkinsServerPublicIp, bitBucketServerELB, bitBucketServerPublicIp, "../terraform-unix-noinstances-jazz/variables.tf",jenkinsServerSSHLogin,bitBucketServerSSHLogin]
subprocess.call(cmd)
cmd = ["./scripts/createTags.sh", tagEnvPrefix, tagApplication, tagEnvironment, tagExempt, tagOwner, "../terraform-unix-noinstances-jazz/envprefix.tf"]
subprocess.call(cmd)

cognito_emailID = raw_input("Please provide valid email ID to login to Jazz Application: ")
cognito_passwd = passwd_generator()
subprocess.call(['sed', '-i', "s|default = \"cognito_pool_username\"|default = \"%s\"|g" %(cognito_emailID), "../terraform-unix-noinstances-jazz/variables.tf"])
subprocess.call(['sed', '-i', "s|default = \"cognito_pool_password\"|default = \"%s\"|g" %(cognito_passwd), "../terraform-unix-noinstances-jazz/variables.tf"])

os.chdir("../terraform-unix-noinstances-jazz")
subprocess.call('nohup ./scripts/create.sh >>../../stack_creation.out&', shell=True)
subprocess.call('cp ./scripts/destroy.sh ../../', shell=True)
print("\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory to see the stack creation progress ")
print(os.path.realpath('../../'))
print("\n\n")

