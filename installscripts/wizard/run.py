#!/usr/bin/python
from __future__ import print_function
import os
import sys
import subprocess
def is_non_zero_file(fpath):  
    return os.path.isfile(fpath) and os.path.getsize(fpath) > 0
def pause():
    programPause = raw_input("Press the <ENTER> key to continue...")

tagEnvPrefix = raw_input("Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): ") 
tagApplication="JAZZ"
tagEnvironment="Development"
tagExempt="09/01/2017"
tagOwner="sukeshsugunan"
cidr="10.0.0.0/16"
cidrcheck="aws ec2 describe-subnets --filters Name=cidrBlock,Values="+cidr+" --output=text > ./cidrexists"
fullstack = raw_input("Do you need full stack including network(Y/N): ") 

if fullstack == "y" or  fullstack == "Y" : # no inputs fomr the client. Create network stack and Jenkins and bitbucket servers
	os.chdir("../terraform-unix-networkstack")
	subprocess.call('pwd', shell=True)
	cmd = ["./scripts/createTags.sh", tagEnvPrefix, tagApplication, tagEnvironment, tagExempt, tagOwner, "../terraform-unix-networkstack/envprefix.tf"]
	subprocess.call(cmd)
	cmd = ["./scripts/createTags.sh", tagEnvPrefix, tagApplication, tagEnvironment, tagExempt, tagOwner, "../terraform-unix-demo-jazz/envprefix.tf"]
	subprocess.call(cmd)
	print (" cidrcheck command = ",cidrcheck)
	subprocess.call(cidrcheck, shell=True)
	if is_non_zero_file("./cidrexists") != True : 
		cmd = ["./scripts/create.sh", cidr]
		subprocess.call(cmd)
		os.chdir("../terraform-unix-demo-jazz")
		subprocess.call('nohup ./scripts/create.sh &', shell=True)
		print("\n\nPlease execute  tail -f nohup.out |grep 'Creation complete' in the below directory to see the stack creation progress ")
		subprocess.call('pwd', shell=True)
		print("\n\n")
	else :  # 
		print("default CIDR "+cidr+" already exists. Please try creating the stack again by providing own subnet ")
		sys.exit()
elif fullstack == "n" or  fullstack == "N" : # use client provided network stack as if jenkins/bitbucket servers exist
	existingJenkinsBitbucket = raw_input("Do you have existing Jenkins and Bitbucket Server(Y/N): ") 
	if existingJenkinsBitbucket == "y" or existingJenkinsBitbucket == "Y" :
		print(" Please create the following adminid/password on Jenkins Server before you proceed: jenkinsadmin/jenkinsadmin")
		print(" Please create the following adminid/password on Bitbucket Server before you proceed: jenkins1/jenkinsadmin")
		pause()
		jenkinsServerELB = raw_input("Please provide Jenkins Server ELB URL: ") 
		jenkinsServerPublicIp = raw_input("Please provide Jenkins Server PublicIp: ") 
		bitBucketServerELB = raw_input("Please provide Bitbuckket  Server ELB URL: ") 
		bitBucketServerPublicIp = raw_input("Please provide bitbucket Server PublicIp: ") 

		os.chdir("../terraform-unix-networkstack")
		cmd = ["./scripts/createServerVars.sh", jenkinsServerELB, jenkinsServerPublicIp, bitBucketServerELB, bitBucketServerPublicIp, "../terraform-unix-noinstances-jazz/variables.tf"]
		subprocess.call(cmd)
		cmd = ["./scripts/createTags.sh", tagEnvPrefix, tagApplication, tagEnvironment, tagExempt, tagOwner, "../terraform-unix-noinstances-jazz/envprefix.tf"]
		subprocess.call(cmd)
		os.chdir("../terraform-unix-noinstances-jazz")
		subprocess.call('nohup ./scripts/create.sh &', shell=True)
		print("\n\nPlease execute  tail -f nohup.out | grep 'Creation complete' in the below directory to see the stack creation progress ")
		subprocess.call('pwd', shell=True)
		print("\n\n")
	elif existingJenkinsBitbucket == "n" or  existingJenkinsBitbucket == "N" :
		print(" We will create Jenkins and Bitbucket Servers using the Network Stack you provided")
		print(" Please have vpc,subnet and cidr blocks handy")
		subnet = raw_input("Please provide subnet id: ") 

		print("\n\n--------------------------------------------------")
		print("The stack will be built using the following info")
		print("SUBNET : ",subnet)

		os.chdir("../terraform-unix-networkstack")
		cmd = ["./scripts/createNetVars.sh",  subnet, "../terraform-unix-demo-jazz/netvars.tf"]
		subprocess.call(cmd)
		cmd = ["./scripts/createTags.sh", tagEnvPrefix, tagApplication, tagEnvironment, tagExempt, tagOwner, "../terraform-unix-demo-jazz/envprefix.tf"]
		subprocess.call(cmd)
		os.chdir("../terraform-unix-demo-jazz")
		subprocess.call('nohup ./scripts/create.sh &', shell=True)
		print("\n\nPlease execute  tail -f nohup.out |grep 'Creation complete' in the below directory to see the stack creation progress")
		subprocess.call('pwd', shell=True)
		print("\n\n")
	else :  # 
		print("invalid input..please try again...")

else:
	print("in valid input..please try again...")
	subprocess.call(['df', '-h'], shell=True)


