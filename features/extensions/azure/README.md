## Summary
Installing this extension will create and configure Azure resources. Once successfully installed, Jazz will be able to expose [Azure] as a deployment target for APIs.

## Benefits
- Jazz admins will now be able to offer more than one deployment targets for deploying their API endpoints
- Developers can now choose Azure as their API deployment target without worrying about the underlying Azure infrastructure, setup & management

## Prerequisites
- Make sure you have an active Azure account with the following details -  AZURE_SUBSCRIPTION_ID, AZURE_LOCATION, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID, AZURE_COMPANY_NAME and AZURE_COMPANY_EMAIL

## Basic Usage

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Azure.py install [OPTIONS]
Options:
  --jazz-stackprefix TEXT       Stackprefix of your Jazz installation (e.g.
                                myjazz), your existing config will be imported
  --jenkins-url TEXT            Specify the url of the Jenkins install
  --jenkins-user TEXT           Admin username for configuration changes
  --jenkins-api-token TEXT      Admin API token for configuration changes
  --jazz-apiendpoint TEXT       Specify the Jazz Endpoint
  --jazz-username TEXT          Specify the Jazz Admin username
  --jazz-password TEXT          Specify the Jazz Admin password
  --azure-subscription-id TEXT  Specify the ID for the azure subscription to
                                deploy functions into
  --azure-location TEXT         Specify the location to install functions
  --azure-client-id TEXT        Specify the client id for the Service
                                Principal used to build infrastructure
  --azure-client-secret TEXT    Specify the password for Service Principal
  --azure-tenant-id TEXT        Specify the Azure AD tenant id for the Service
                                Principal
  --azure-company-name TEXT     Specify the company name used in the Azure API
                                Management service
  --azure-company-email TEXT    Specify the company contact email used in the
                                Azure API Management service
  --azure-apim-dev-sku TEXT     The SKU for the Azure API Management service
                                for the development environment  [default:
                                (Developer)]
  --azure-apim-stage-sku TEXT   The SKU for the Azure API Management service
                                for the staging environment  [default:
                                (Developer)]
  --azure-apim-prod-sku TEXT    The SKU for the Azure API Management service
                                for the production environment  [default:
                                (Developer)]
  --help                        Show this message and exit.

```
Note:
   - JAZZ_INSTALLER_DIRECTORY - Directory path of jazz installation
   - Both the  install/uninstall options will ask user for raw inputs for all the missing arguments (similar to below)
```sh
    Jazz stackprefix:
    Jazz apiendpoint:
```

## Example (Install option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Azure.py install --jazz-stackprefix STACKPREFIX
                  --jazz-apiendpoint JAZZ_APIENDPOINT
                  --jazz-username JAZZADMIN
                  --jazz-password JAZZPASSWORD
                  --jenkins-url JENKINSURL
                  --jenkins-user JENKINSUSER
                  --jenkins-api-token JENKINSPASSWORD OR TOKEN
                  --azure-subscription-id AZURE_SUBSCRIPTION_ID
                  --azure-location AZURE_LOCATION
                  --azure-client-id AZURE_CLIENT_ID
                  --azure-client-secret AZURE_CLIENT_SECRET
                  --azure-tenant-id AZURE_TENANT_ID
                  --azure-company-name AZURE_COMPANY_NAME
                  --azure-company-email AZURE_COMPANY_EMAIL
```

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Azure.py install

# Enter the missing input params
Jazz stackprefix:
Jenkins url:
Jenkins user:
Jenkins api token:
Jazz apiendpoint:
Jazz username:
Jazz password:
Azure subscription id:
Azure location:
Azure client id:
Azure client secret:
Azure tenant id:
Azure company name:
Azure company email:
```


## Example (Uninstall option)

### With all the parameters as arguments

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Azure.py uninstall --jazz-stackprefix STACKPREFIX
                  --jazz-apiendpoint JAZZ_APIENDPOINT
                  --jazz-username JAZZADMIN
                  --jazz-password JAZZPASSWORD
                  --jenkins-url JENKINSURL
                  --jenkins-user JENKINSUSER
                  --jenkins-api-token JENKINSPASSWORD OR TOKEN
                  --azure-subscription-id AZURE_SUBSCRIPTION_ID
                  --azure-location AZURE_LOCATION
                  --azure-client-id AZURE_CLIENT_ID
                  --azure-client-secret AZURE_CLIENT_SECRET
                  --azure-tenant-id AZURE_TENANT_ID
                  --azure-company-name AZURE_COMPANY_NAME
                  --azure-company-email AZURE_COMPANY_EMAIL

```

### With missing parameters as arguments ###

```sh
cd JAZZ_INSTALLER_DIRECTORY/features
python Azure.py uninstall

# Enter the missing input params
Jazz stackprefix:
Jenkins url:
Jenkins user:
Jenkins api token:
Jazz apiendpoint:
Jazz username:
Jazz password:
Azure subscription id:
Azure location:
Azure client id:
Azure client secret:
Azure tenant id:
Azure company name:
Azure company email:
```
