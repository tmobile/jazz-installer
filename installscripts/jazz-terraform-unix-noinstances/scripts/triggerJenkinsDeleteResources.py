#!/usr/bin/env python2
import argparse
import subprocess

def main():
  parser = argparse.ArgumentParser()

  parser.add_argument(
    '--jenkins-url',
    help='Specify the Jenkins url'
  )

  parser.add_argument(
    '--jenkins-username',
    help='Specify the Jenkins username'
  )

  parser.add_argument(
    '--jenkins-password',
    help='Specify the Jenkins password'
  )

  args = parser.parse_args()
  startJob(args)


def startJob(args):
  collectUserInput(args)
  subprocess.check_call(
    [
      "curl",
      "-sL",
      ("http://%s/jnlpJars/jenkins-cli.jar") %
      (args.jenkins_url),
      "-o",
      "jenkins-cli.jar"])


  jenkins_build_command = " java -jar jenkins-cli.jar -s http://%s -auth %s:%s build jenkins-delete-resources  -p input=all" %(
                          args.jenkins_url,
                          args.jenkins_username,
                          args.jenkins_password
  ) 

  subprocess.call(jenkins_build_command,shell=True)
  
def collectUserInput(args):
  
  if not args.jenkins_url:
    args.jenkins_url = raw_input("Please enter the Jenkins URL(without http): ")

  if not args.jenkins_username:
    args.jenkins_username = raw_input("Please enter the Jenkins Username: ")

  if not args.jenkins_password:
    args.jenkins_password = raw_input("Please enter the Jenkins Password: ")


main()