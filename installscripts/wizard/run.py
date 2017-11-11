#!/usr/bin/python
from __future__ import print_function
import os
import sys
import subprocess
import datetime
import string
import random

devnull = open(os.devnull, 'w')

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
def passwd_generator():
    length = 10
    pwd = []
    pwd.append(random.choice(string.ascii_lowercase))
    pwd.append(random.choice(string.ascii_uppercase))
    pwd.append(random.choice(string.digits))
    pwd.append("@")
    for x in range(6):
        pwd.append(random.choice(string.letters))
    random.shuffle(pwd)
    return ''.join(pwd)

def check_jenkins_user(url, username, passwd):
    cli_url = 'http://' + url +':8080/jnlpJars/jenkins-cli.jar'
    cmd = ['curl','-s', cli_url, '--output', 'jenkins-cli.jar']
    subprocess.call(cmd, stdout=devnull)

    jenkins_url = 'http://' + url +':8080'
    cmd = ['/usr/bin/java', '-jar', 'jenkins-cli.jar', '-s', jenkins_url, 'who-am-i', '--username', username, '--password', passwd]
    subprocess.call(cmd, stdout=open("output", 'w'), stderr=open("output", 'w'))

    if 'authenticated' in open('output').read():
        os.remove('output')
        os.remove('jenkins-cli.jar')
        return 1
    else:
        os.remove('output')
        os.remove('jenkins-cli.jar')
        return 0

def check_bitbucket_user(url, username, passwd):
    url = 'http://' + bitbucketServerELB + ':7990'

    bitbucket = os.path.realpath("/home/ec2-user/atlassian-cli-6.7.1/bitbucket.sh")
    subprocess.call(['sudo', 'chmod', '+x', bitbucket])
    cmd = [ bitbucket , '--action', 'createproject', '--project', 'test000', '--name', 'test000', '--server', url, '--user', username, '--password', passwd]
    subprocess.call(cmd, stdout=open("out_bitbucket", 'w'), stderr=open("out_bitbucket", 'w'))

    if 'Remote' in open("out_bitbucket").read():
        os.remove("out_bitbucket")
        return 0
    else:
        cmd = [bitbucket, '--action', 'deleteproject', '--project', 'test000', '--server', url, '--user', username, '--password', passwd]
        subprocess.call(cmd, stdout=devnull, stderr=devnull)
        os.remove("out_bitbucket")
        return 1


tagEnvPrefix = raw_input("Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): ")
tagApplication="JAZZ"
tagEnvironment="Development"
tagExempt=(datetime.datetime.today()+datetime.timedelta(days=1)).strftime("%m/%d/%Y")
tagOwner=tagEnvPrefix+"-Admin"

jenkinsServerELB = raw_input("Please provide Jenkins URL (Please ignore http and port number from URL): ")
jenkinsuser = raw_input("Please provide username for Jenkins:")
jenkinspasswd = raw_input("Please provide password for Jenkins:")
if check_jenkins_user(jenkinsServerELB, jenkinsuser, jenkinspasswd):
    print("Great! We can proceed with this jenkins user....We will need few more details of Jenkins server")
else:
    sys.exit("Kindly provide an 'Admin' Jenkins user with correct password and run the installer again!")
jenkinsServerPublicIp = raw_input("Please provide Jenkins Server PublicIp: ")
jenkinsServerSSHLogin = raw_input("Please provide Jenkins Server SSH login name: ")

bitbucketServerELB = raw_input("Please provide Bitbucket URL (Please ignore http and port number from URL): ")
bitbucketuser = raw_input("Please provide username for Bitbucket:")
bitbucketpasswd = raw_input("Please provide password for Bitbucket:")
if check_bitbucket_user(bitbucketServerELB, bitbucketuser, bitbucketpasswd):
    print("Great! We can proceed with this Bitbucket user....We will need few more details of Bitbucket server")
else:
    sys.exit("Kindly provide an 'Admin' Bitbucket user with correct password and run the installer again!")
bitBucketServerPublicIp = raw_input("Please provide bitbucket Server PublicIp: ")
bitBucketServerSSHLogin = raw_input("Please provide bitbucket SSH login name: ")


print(" Please make sure that you have the ssh login user names of jenkins and bitbucket servers.")
print(" Please create jenkinskey.pem and bitbucketkey.pem with private keys of Jenkins and Bitbucket in /home/ec2-user")
pause()

subprocess.call('cp -f ../../../jenkinskey.pem ../sshkeys && sudo chmod 400 ../sshkeys/jenkinskey.pem', shell=True)
subprocess.call('cp -f ../../../bitbucketkey.pem ../sshkeys/ && sudo chmod 400 ../sshkeys/bitbucketkey.pem', shell=True)


os.chdir("../terraform-unix-networkstack")
cmd = ["./scripts/createServerVars.sh", jenkinsServerELB, jenkinsServerPublicIp, bitBucketServerELB, bitBucketServerPublicIp, "../terraform-unix-noinstances-jazz/variables.tf",jenkinsServerSSHLogin,bitBucketServerSSHLogin,jenkinsuser, jenkinspasswd, bitbucketuser, bitbucketpasswd]
subprocess.call(cmd)
cmd = ["./scripts/createTags.sh", tagEnvPrefix, tagApplication, tagEnvironment, tagExempt, tagOwner, "../terraform-unix-noinstances-jazz/envprefix.tf"]
subprocess.call(cmd)

cognito_emailID = raw_input("Please provide valid email ID to login to Jazz Application: ")
cognito_passwd = passwd_generator()
subprocess.call(['sed', '-i', "s|default = \"cognito_pool_username\"|default = \"%s\"|g" %(cognito_emailID), "../terraform-unix-noinstances-jazz/variables.tf"])
subprocess.call(['sed', '-i', "s|default = \"cognito_pool_password\"|default = \"%s\"|g" %(cognito_passwd), "../terraform-unix-noinstances-jazz/variables.tf"])

# Providing stack name to destroy script.
subprocess.call(['sed', '-i', "s|stack_name=\"\"|stack_name\"%s\"|g" %(tagEnvPrefix), "../terraform-unix-noinstances-jazz/scripts/destroy.sh"])
subprocess.call(['sed', '-i', "s|<username>bitbucketuser</username>|<username>%s</username>|g" %(bitbucketuser), "../cookbooks/jenkins/files/credentials/jenkins1.sh"])
subprocess.call(['sed', '-i', "s|<password>bitbucketpasswd</password>|<password>%s</password>|g" %(bitbucketpasswd), "../cookbooks/jenkins/files/credentials/jenkins1.sh"])
subprocess.call(['sed', '-i', "s|jenkinsuser:jenkinspasswd|%s:%s|g" %(jenkinsuser, jenkinspasswd), "../cookbooks/jenkins/default/authfile"])

os.chdir("../terraform-unix-noinstances-jazz")
subprocess.call('nohup ./scripts/create.sh >>../../stack_creation.out&', shell=True)
subprocess.call('cp ./scripts/destroy.sh ../../', shell=True)
print("\n\nPlease execute  tail -f stack_creation.out | grep 'Creation complete' in the below directory to see the stack creation progress ")
print(os.path.realpath('../../'))
print("\n\n")
