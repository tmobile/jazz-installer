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
cd JAZZ_INSTALLER_DIRECTORY/features
python Apigee.py install [OPTIONS]
Options:
  -r, --region [us-east-1|us-west-2]
                                  Specify the region where your Jazz
                                  installation lives
  -p, --stackprefix TEXT          Specify the stackprefix of your existing
                                  Jazz installation (e.g. myjazz),
                                  your existing config will be imported
  --jazz_apiendpoint TEXT     Specify the Jazz Endpoint
  --jazz_userpass TEXT...         Provide the username and password     of the
                                  jazz application separated by a space
                                  [required]
  --jenkins_url TEXT              Specify the Jenkins url
  --jenkins_userpass TEXT...      Provide the username and password     of the
                                  jenkins separated by a space  [required]
  --apigee_host TEXT              Url of the Apigee host (e.g. https://my-
                                  apigee-host)
  --apigee_org TEXT               Name of the Apigee org you wish to use
  --apigee_prod_env TEXT          Name of the Apigee env you wish to use (e.g.
                                  prod)
  --apigee_dev_env TEXT           Name of the Apigee env you wish to use (e.g.
                                  dev)
  --apigee_svc_prod_host TEXT     Url of the service API host (e.g.
                                  jazz.api.prod.com)
  --apigee_svc_dev_host TEXT      Url of the service API host (e.g.
                                  jazz.api.dev.com)
  --apigee_userpass TEXT...       Provide the username and password     when
                                  accessing Apigee separated by a space
                                  [required]
  --accesskey TEXT                AWS accesskey of the apigee user account
  --secretkey TEXT                AWS secretkey of the apigee user account
  --help                          Show this message and exit.

```
Note:
   - JAZZ_INSTALLER_DIRECTORY - Directory path of jazz installation
   - Both the  install/uninstall options will ask user for raw inputs for all the missing arguments (similar to below)
```sh
    Stackprefix:
    Jazz apiendpoint:
```

## Example (Install option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Apigee.py install --region REGION
                  --stackprefix STACKPREFIX
                  --jazz_apiendpoint JAZZ_APIENDPOINT
                  --jazz_userpass JAZZADMIN JAZZPASSWORD
                  --jenkins_url JENKINSURL
                  --jenkins_userpass JENKINSUSER JENKINSPASSWORD
                  --apigee_host https://api.enterprise.apigee.com
                  --apigee_org APIGEEORG
                  --apigee_prod_env PRODENV
                  --apigee_dev_env DEVENV
                  --apigee_svc_prod_host APIGEE_PROD_SERVICEHOST
                  --apigee_svc_dev_host APIGEE_DEV_SERVICEHOST
                  --apigee_userpass APIGEEUSERNAME APIGEEPASSWORD
                  --accesskey APIGEEAWSACCESSKEY
                  --secretkey APIGEEAWSSECRETKEY

```

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Apigee.py install

# Enter the missing input params
Stackprefix:
Jazz apiendpoint:
Jazz userpass [()]:
Jenkins url:
Jenkins userpass [()]:
Apigee host:
Apigee org:
Apigee prod env:
Apigee dev env:
Apigee svc prod host:
Apigee svc dev host:
Apigee userpass [()]:
AWS accesskey:
Aws secretkey:
```


## Example (Uninstall option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Apigee.py uninstall --region REGION
                  --stackprefix STACKPREFIX
                  --jazz_userpass JAZZADMIN JAZZPASSWORD
                  --jazz_apiendpoint JAZZ_APIENDPOINT
                  --jenkins_url JENKINSURL
                  --jenkins_userpass JENKINSUSER JENKINSPASSWORD

```

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Apigee.py uninstall

# Enter the missing input params
Stackprefix:
Jazz userpass [()]:
Jazz apiendpoint:
Jenkins url:
Jenkins userpass [()]:
```
