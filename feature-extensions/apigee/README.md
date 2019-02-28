## Summary
Installing this extension will create and configure Apigee resources. Once successfully installed, Jazz will be able to expose [Apigee](https://apigee.com/api-management/#/homepage) as a deployment target for APIs.

## Benefits
- Jazz admins will now be able to offer more than one deployment targets for deploying their API endpoints
- Developers can now choose Apigee as their API deployment target without worrying about the underlying Apigee infrastructure, setup & management

## Prerequisites
- Make sure you have an active Apigee account with at least two environments
- Installer will use the AWS credentials that you have configured in your system by running 'aws configure'
- Please make sure that you use the same AWS credentials that were used to install Jazz

## Basic Usage

```sh
cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/apigee
python setup.py [-h] [--aws-region AWS_REGION]
                [--jazz-stackprefix JAZZ_STACKPREFIX] [--scm-repo SCM_REPO]
                [--scm-username SCM_USERNAME] [--scm-password SCM_PASSWORD]
                [--scm-pathext SCM_PATHEXT] [--jenkins-url JENKINS_URL]
                [--jenkins-username JENKINS_USERNAME]
                [--jenkins-password JENKINS_PASSWORD]
                {install,uninstall} ... apigee_host apigee_org apigee_prod_env
                apigee_dev_env apigee_svc_prod_host apigee_svc_dev_host
                apigee_username apigee_password
```
Note:
   - JAZZ_INSTALLER_DIRECTORY - Directory path of jazz installation
   - Both the  install/uninstall options will ask user for raw inputs for all the missing arguments (similar to below)
```sh
          Please enter the SCM Repo:
          Please enter the SCM Username:
          Please enter the SCM Password:
          Please enter the SCM Pathext (Use "/scm" for bitbucket):
          Please enter the Jenkins URL(without http):
          Please enter the Jenkins Username:
          Please enter the Jenkins Password:
```

## Example (Install option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/apigee
python setup.py --aws-region REGION 
                  --jazz-stackprefix STACKPREFIX 
                  --scm-repo SCMREPO 
                  --scm-username SCMUSERNAME 
                  --scm-password SCMPASSWORD 
                  --scm-pathext / 
                  --jenkins-url JENKINSURL 
                  --jenkins-username JENKINSUSER 
                  --jenkins-password JENKINSPASSWORD 
                  install https://api.enterprise.apigee.com APIGEEORG PRODENV DEVENV APIGEE_PROD_SERVICEHOST APIGEE_DEV_SERVICEHOST APIGEEUSERNAME APIGEEPASSWORD
```

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/apigee
python setup.py install https://api.enterprise.apigee.com APIGEEORG PRODENV DEVENV APIGEE_PROD_SERVICEHOST APIGEE_DEV_SERVICEHOST APIGEEUSERNAME APIGEEPASSWORD

# Enter the missing input params
Please enter the SCM Repo:
Please enter the SCM Username:
Please enter the SCM Password:
Please enter the SCM Pathext (Use "/scm" for bitbucket):
Please enter the Jenkins URL(without http):
Please enter the Jenkins Username:
Please enter the Jenkins Password:
```
