## Summary
- **Make sure you have an Apigee account with at least two environments**
- **This installer will use whatever AWS credentials you have configured by running 'aws configure'**
- **Please make sure you are using the same AWS credentials you used to install your Jazz deployment**

## USAGE
 ```
  #  cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/apigee
  #  python setup.py [-h] [--aws-region AWS_REGION]
                [--jazz-stackprefix JAZZ_STACKPREFIX] [--scm-repo SCM_REPO]
                [--scm-username SCM_USERNAME] [--scm-password SCM_PASSWORD]
                [--scm-pathext SCM_PATHEXT] [--jenkins-url JENKINS_URL]
                [--jenkins-username JENKINS_USERNAME]
                [--jenkins-password JENKINS_PASSWORD]
                {install,uninstall} ... apigee_host apigee_org apigee_prod_env
                apigee_dev_env apigee_svc_prod_host apigee_svc_dev_host
                apigee_username apigee_password

 Note:
   - JAZZ_INSTALLER_DIRECTORY - Directory path of jazz installation
   - Both the  install/uninstall will ask user raw inputs for all the the missing arguments.
     -- It will ask to enter the user inputs like below,
          Please enter the SCM Repo:
          Please enter the SCM Username:
          Please enter the SCM Password:
          Please enter the SCM Pathext (Use "/scm" for bitbucket):
          Please enter the Jenkins URL(without http):
          Please enter the Jenkins Username:
          Please enter the Jenkins Password:

 ```

## INSTALL ##

### With all the parameters as argument ###
**Follow the below steps**
```
# cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/apigee
# python setup.py --aws-region REGION --jazz-stackprefix STACKPREFIX --scm-repo SCMREPO --scm-username SCMUSERNAME --scm-password SCMPASSWORD --scm-pathext / --jenkins-url JENKINSURL --jenkins-username JENKINSUSER --jenkins-password JENKINSPASSWORD install https://api.enterprise.apigee.com APIGEEORG PRODENV DEVENV APIGEE_PROD_SERVICEHOST APIGEE_DEV_SERVICEHOST APIGEEUSERNAME APIGEEPASSWORD
```

### With missing parameters as argument ###
**Follow the below steps**
```
# cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/apigee
# python setup.py install https://api.enterprise.apigee.com APIGEEORG PRODENV DEVENV APIGEE_PROD_SERVICEHOST APIGEE_DEV_SERVICEHOST APIGEEUSERNAME APIGEEPASSWORD
# Enter the missing input params
```

## UNINSTALL ##

### With all the parameters as argument ###
**Follow the below steps**
```
# cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/apigee
# python setup.py --aws-region REGION --jazz-stackprefix STACKPREFIX --scm-repo SCMREPO --scm-username SCMUSERNAME --scm-password SCMPASSWORD --scm-pathext / --jenkins-url JENKINSURL --jenkins-username JENKINSUSER --jenkins-password JENKINSPASSWORD uninstall https://api.enterprise.apigee.com APIGEEORG PRODENV DEVENV APIGEE_PROD_SERVICEHOST APIGEE_DEV_SERVICEHOST APIGEEUSERNAME APIGEEPASSWORD
```

## With missing parameters as argument ###
**Follow the below steps**
```
# cd JAZZ_INSTALLER_DIRECTORY/feature-extensions/apigee
# python setup.py uninstall https://api.enterprise.apigee.com APIGEEORG PRODENV DEVENV APIGEE_PROD_SERVICEHOST APIGEE_DEV_SERVICEHOST APIGEEUSERNAME APIGEEPASSWORD
# Enter the missing input params
```
