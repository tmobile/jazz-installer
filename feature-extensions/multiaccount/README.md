## Summary
Installing this extension will allow the user to deploy API, Lambda and Websites in multiple AWS account and multiple regions.

## Benefits
- Jazz admins will now be able to offer more flexibility in deploying services in different regions and different accounts

## Prerequisites
- Make sure you have an admin AWS account and it will be used while installing the feature extension for multiaccount
- Installer will use the AWS credentials that you have configured in your system by running 'aws configure'

## Basic Usage

```sh
cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/multiaccount
python setup.py [-h] [--aws-region AWS_REGION]
                [--jazz-stackprefix JAZZ_STACKPREFIX] [--aws-accesskey AWS_ACCESSKEY]
                [--aws-secretkey AWS_SECRETKEY] [--jenkins-url JENKINS_URL]
                [--jenkins-username JENKINS_USERNAME]
                [--jenkins-password JENKINS_PASSWORD]
                [--jazz-username JAZZ_USERNAME]
                [--jazz-password JAZZ_PASSWORD]
                [--jazz-apiendpoint JAZZ_APIENDPOINT]
                {install} ...
```
Note:
   - JAZZ_INSTALLER_DIRECTORY - Directory path of jazz installation
   - Install option will ask user for raw inputs for all the missing arguments (similar to below)
```sh
    Please enter the environment prefix you used for your Jazz install:
    Enter AWS accesskey of the new account:
    Enter secretkey of the new account:
    Enter AWS regions with space delimiter:
    Please enter the Jenkins URL(without http):
    Please enter the Jenkins Username:
    Please enter the Jenkins Password:
    Please enter the Jazz Admin Username:
    Please enter the Jazz Admin Password:
    Please enter the Jazz API Endpoint(Full URL):
```

## Example (Install option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/multiaccount
python setup.py --aws-region us-east-1 us-west-2
                --jazz-stackprefix STACKPREFIX
                --aws-accesskey XXXXX
                --aws-secretkey XXXXX
                --jenkins-url JENKINSURL
                --jenkins-username JENKINSUSER
                --jenkins-password JENKINSPASSWORD
                --jazz-username JAZZADMIN
                --jazz-password JAZZPASSWORD
                --jazz-apiendpoint JAZZ_APIENDPOINT install

```

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/multiaccount
python setup.py install

# Enter the missing input params
Please enter the environment prefix you used for your Jazz install:
Enter AWS accesskey of the new account:
Enter secretkey of the new account:
Enter AWS regions with space delimiter:
Please enter the Jenkins URL(without http):
Please enter the Jenkins Username:
Please enter the Jenkins Password:
Please enter the Jazz Admin Username:
Please enter the Jazz Admin Password:
Please enter the Jazz API Endpoint(Full URL):
```

## Example (Uninstall option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/multiaccount
python triggerJenkinsDeleteResources.py --jenkins-url JENKINSURL
                                        --jenkins-username JENKINSUSER
                                        --jenkins-password JENKINSPASSWORD --account-details all
```

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/multiaccount
python triggerJenkinsDeleteResources

# Enter the missing input params
Please enter the Jenkins URL(without http):
Please enter the Jenkins Username:
Please enter the Jenkins Password:
Please enter the Accounts to delete '
            '(Empty will delete all):
```
