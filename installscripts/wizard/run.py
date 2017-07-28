#!/usr/bin/python
from __future__ import print_function
import os
import subprocess

fullstack = raw_input("Do you need full stack including network(Y/N): ") 

if fullstack == "y" or  fullstack == "Y" : # no inputs fomr the client. Create network stack and Jenkins and bitbucket servers
	os.chdir("../terraform-unix-networkstack")
	subprocess.call('pwd', shell=True)
	subprocess.call('nohup terraform  apply &', shell=True)
	os.chdir("../terraform-unix-demo-jazz")
	subprocess.call('pwd', shell=True)
	subprocess.call('nohup terraform  apply &', shell=True)
elif fullstack == "n" or  fullstack == "N" : # use client provided network stack as if jenkins/bitbucket servers exist
	existingJenkinsBitbucket = raw_input("Do you have existing Jenkins and Bitbucket Server(Y/N): ") 
	if existingJenkinsBitbucket == "y" or existingJenkinsBitbucket == "Y" :
		jenkinsServerELB = raw_input("Please provide Jenkins Server ELB URL: ") 
		jenkinsServerPublicIp = raw_input("Please provide Jenkins Server PublicIp: ") 
		bitBucketServerELB = raw_input("Please provide Bitbuckket  Server ELB URL: ") 
		bitBucketServerPublicIp = raw_input("Please provide bitbucket Server PublicIp: ") 

		os.chdir("../terraform-unix-networkstack")
		cmd = ["./scripts/createServerVars.sh", jenkinsServerELB, jenkinsServerPublicIp, bitBucketServerELB, bitBucketServerPublicIp, "../terraform-unix-noinstances-jazz/variables.tf"]
		os.chdir("../terraform-unix-noinstances-jazz")
		subprocess.call('pwd', shell=True)
		subprocess.call('nohup terraform  apply &', shell=True)
	elif existingJenkinsBitbucket == "n" or  existingJenkinsBitbucket == "N" :
		print(" We will create Jenkins and Bitbucket Servers using the Network Stack you provided")
		print(" Please have vpc,subnet and cidr blocks handy")
		vpc = raw_input("Please provide VPC id: ") 
		subnet = raw_input("Please provide subnet id: ") 
		cidr  = raw_input("Please provide CIDR BLOCK: ") 

		print("\n\n--------------------------------------------------")
		print("The stack will be built using the following info")
		print("VPC : ",vpc)
		print("SUBNET : ",subnet)
		print("CIDR BLOCK : ",cidr)

		os.chdir("../terraform-unix-networkstack")
		cmd = ["./scripts/createNetVars.sh", vpc, subnet, cidr, "../terraform-unix-demo-jazz/netvars.tf"]
		subprocess.call(cmd,  shell=True)
		os.chdir("../terraform-unix-demo-jazz")
		subprocess.call('pwd', shell=True)
		subprocess.call('nohup terraform  apply &', shell=True)
	else :  # 
		print("invalid input..please try again...")

else:
	print("in valid input..please try again...")
	subprocess.call(['df', '-h'], shell=True)


