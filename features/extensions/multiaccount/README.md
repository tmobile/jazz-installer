## Summary
Installing this extension will allow the user to deploy API, Lambda and Websites in multiple AWS account and multiple regions.

## Benefits
- Jazz admins will now be able to offer more flexibility in deploying services in different regions and different accounts

## Prerequisites
- Make sure you have an admin AWS account and it will be used while installing the feature extension for multiaccount
- Installer will use the AWS credentials that you have configured in your system by running 'aws configure'

## Basic Usage

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Multiaccount.py install [OPTIONS]
Options:
  -r, --regions TEXT          Specify AWS regions you wish to apply on the new
                              account
  -p, --stackprefix TEXT      Specify the stackprefix of your existing Jazz
                              installation (e.g. myjazz),           your
                              existing config will be imported
  --aws_accesskey TEXT        AWS accesskey of the new account
  --aws_secretkey TEXT        AWS secretkey of the new account
  --jazz_apiendpoint TEXT     Specify the Jazz Endpoint
  --jazz_userpass TEXT...     Provide the username and password     of the
                              jazz application separated by a space
                              [required]
  --jenkins_url TEXT          Specify the Jenkins url
  --jenkins_userpass TEXT...  Provide the username and password     of the
                              jenkins separated by a space  [required]
  --help                      Show this message and exit.
```
Note:
   - JAZZ_INSTALLER_DIRECTORY - Directory path of jazz installation
   - Both the  install/uninstall options will ask user for raw inputs for all the missing arguments (similar to below)
```sh
    Regions [()]:
    Stackprefix:
    Aws accesskey:
    Aws secretkey:
    Jazz apiendpoint:
```

## Example (Install option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Multiaccount.py install --regions us-east-1 --regions us-west-2
                --stackprefix STACKPREFIX
                --aws_accesskey XXXXX
                --aws_secretkey XXXXX
                --jazz_apiendpoint JAZZ_APIENDPOINT
                --jazz_userpass JAZZADMIN JAZZPASSWORD
                --jenkins_url JENKINSURL
                --jenkins_userpass JENKINSUSER JENKINSPASSWORD

```

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Multiaccount.py install

# Enter the missing input params
Regions [()]:
Stackprefix:
Aws accesskey:
Aws secretkey:
Jazz apiendpoint:
Jazz userpass [()]:
Jenkins url:
Jenkins userpass [()]:
```

## Example (Uninstall option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Multiaccount.py uninstall
                    --jenkins_url JENKINSURL
                    --jenkins_userpass JENKINSUSER JENKINSPASSWORD
                    --account-details all
```
Note: account-details can be 123XXXXX, 234XXXXX etc

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Multiaccount.py uninstall

# Enter the missing input params
Jenkins url:
Jenkins userpass [()]:
Account details [all]:
```
