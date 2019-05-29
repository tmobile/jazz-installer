import click
import sys
import subprocess
import os

from extensions.apigee import terraformBugWorkaround
from extensions.apigee.apigeeinstaller.init_apigee_install import install_proxy
from utils.api_config import update_config
from utils.jenkins import setCredential, startJob


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


featureName = "Apigee"
# The lambda function created has the format of ENVPREFIX-jazz-apigee-proxy-aws-STAGE
gatewayFunctionName = "jazz-apigee-proxy-aws-prod"
terraformGatewayResource = "aws_lambda_function.jazz-apigee-proxy"


@click.command()
@click.option(
    "--region",
    "-r",
    help='Specify the region where your Jazz installation lives',
    type=click.Choice(['us-east-1', 'us-west-2']),
    default='us-east-1'
)
@click.option(
    "--stackprefix",
    "-p",
    help='Specify the stackprefix of your existing Jazz installation (e.g. myjazz), \
          your existing config will be imported',
    prompt=True
)
@click.option(
    "--jazz_apiendpoint",
    help='Specify the Jazz Endpoint',
    prompt=True
)
@click.option(
    '--jazz_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the jazz application separated by a space',
    prompt=True)
@click.option(
    "--jenkins_url",
    help='Specify the Jenkins url',
    prompt=True
)
@click.option(
    '--jenkins_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the jenkins separated by a space',
    prompt=True)
@click.option(
    "--apigee_host",
    help='Url of the Apigee host (e.g. https://my-apigee-host)',
    prompt=True
)
@click.option(
    "--apigee_org",
    help='Name of the Apigee org you wish to use',
    prompt=True
)
@click.option(
    "--apigee_prod_env",
    help='Name of the Apigee env you wish to use (e.g. prod)',
    prompt=True
)
@click.option(
    "--apigee_dev_env",
    help='Name of the Apigee env you wish to use (e.g. dev)',
    prompt=True
)
@click.option(
    "--apigee_svc_prod_host",
    help='Url of the service API host (e.g. jazz.api.prod.com)',
    prompt=True
)
@click.option(
    "--apigee_svc_dev_host",
    help='Url of the service API host (e.g. jazz.api.dev.com)',
    prompt=True
)
@click.option(
    '--apigee_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password when accessing Apigee separated by a space',
    prompt=True)
def install(region, stackprefix, jazz_apiendpoint, jazz_userpass, jenkins_url,
            jenkins_userpass, apigee_host, apigee_org, apigee_prod_env, apigee_dev_env,
            apigee_svc_prod_host, apigee_svc_dev_host, apigee_userpass):
    click.secho('\n\nThis will install {0} functionality into your Jazz \
                deployment'.format(featureName), fg='blue')
    click.secho('\nThis installer will use whatever AWS credentials you have configured by \
                running `aws configure`', fg='green')
    click.secho('\nPlease make sure you are using the same AWS credentials you used to \
                install your Jazz deployment', fg='green')
    # Run terraform first, as we need it's output
    runTerraform(region, getAWSAccountID(), stackprefix, True)
    # TODO remove this entire module when the terraform bug is fixed
    click.secho('\nLinking new role to existing gateway function', fg='blue')
    terraformBugWorkaround.linkNewRoleToExistingFunctionWithCLI(stackprefix + "-" + gatewayFunctionName)
    jazz_userpass_list = ''.join(list(jazz_userpass)).split()
    jazz_username, jazz_password = jazz_userpass_list[0], jazz_userpass_list[1]
    jenkins_userpass_list = ''.join(list(jenkins_userpass)).split()
    jenkins_username, jenkins_password = jenkins_userpass_list[0], jenkins_userpass_list[1]
    apigee_userpass_list = ''.join(list(apigee_userpass)).split()
    apigee_username, apigee_password = apigee_userpass_list[0], apigee_userpass_list[1]
    install_proxy(
        getTerraformOutputVar("apigee-lambda-user-secret-key"),
        getTerraformOutputVar("apigee-lambda-user-id"),
        region,
        getTerraformOutputVar("apigee-lambda-gateway-func-arn"),
        apigee_host,
        apigee_org,
        apigee_prod_env,
        apigee_dev_env,
        "1.0",
        apigee_username,
        apigee_password
    )
    credential_id = "ApigeeforJazz"
    apigee_json = prepare_apigee_json(
        apigee_host,
        credential_id,
        apigee_prod_env,
        apigee_dev_env,
        apigee_svc_prod_host,
        apigee_svc_dev_host,
        apigee_org
    )

    update_config(
        "APIGEE",
        apigee_json,
        jazz_username,
        jazz_password,
        jazz_apiendpoint
    )

    # Store the CREDENTIAL_ID in jenkins
    setCredential(jenkins_url, jenkins_username, jenkins_password, credential_id,
                  apigee_username, apigee_password)
    # Trigger metrics api
    metricJobUrl = "job/build-pack-api/buildWithParameters?token=jazz-101-job&service_name=metrics&domain" \
                   "=jazz&scm_branch=master"
    startJob(jenkins_url, jenkins_username, jenkins_password, metricJobUrl)
    # Trigger jazz ui
    startJob(jenkins_url, jenkins_username, jenkins_password, "job/jazz_ui/build?token=jazz-101-job")


@click.command()
@click.option(
    "--region",
    "-r",
    help='Specify the region where your Jazz installation lives',
    type=click.Choice(['us-east-1', 'us-west-2']),
    default='us-east-1'
)
@click.option(
    "--stackprefix",
    "-p",
    help='Specify the stackprefix of your existing Jazz installation (e.g. myjazz), \
          your existing config will be imported',
    prompt=True
)
@click.option(
    '--jazz_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the jazz application separated by a space',
    prompt=True)
@click.option(
    "--jazz_apiendpoint",
    help='Specify the Jazz Endpoint',
    prompt=True
)
@click.option(
    "--jenkins_url",
    help='Specify the Jenkins url',
    prompt=True
)
@click.option(
    '--jenkins_userpass',
    nargs=2,
    required=True,
    help='Provide the username and password \
    of the jenkins separated by a space',
    prompt=True)
def uninstall(region, stackprefix, jazz_userpass, jazz_apiendpoint, jenkins_url, jenkins_userpass):
    click.secho('\n\nThis will remove {0} functionality from your Jazz deployment'.format(featureName), fg='blue')
    terraformStateSanityCheck()

    # TODO remove this entire module when the terraform bug is fixed
    click.secho('\nRestoring old role to gateway function', fg='blue')

    # Restore old role first, before we destroy the Terraform resources
    terraformBugWorkaround.restoreOldRoleToExistingFunctionWithCLI(stackprefix + "-" + gatewayFunctionName)
    jazz_userpass_list = ''.join(list(jazz_userpass)).split()
    jazz_username, jazz_password = jazz_userpass_list[0], jazz_userpass_list[1]
    jenkins_userpass_list = ''.join(list(jenkins_userpass)).split()
    jenkins_username, jenkins_password = jenkins_userpass_list[0], jenkins_userpass_list[1]
    runTerraform(region, getAWSAccountID(), stackprefix, False)
    update_config(
        "APIGEE.ENABLE_APIGEE",
        'false',
        jazz_username,
        jazz_password,
        jazz_apiendpoint
    )
    # Trigger metrics api
    metricJobUrl = "job/build-pack-api/buildWithParameters?token=jazz-101-job&service_name=metrics&domain" \
                   "=jazz&scm_branch=master"
    startJob(jenkins_url, jenkins_username, jenkins_password, metricJobUrl)
    # Trigger jazz ui
    startJob(jenkins_url, jenkins_username, jenkins_password, "job/jazz_ui/build?token=jazz-101-job")


def runTerraform(region, accountId, envPrefix, install):
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='extensions/apigee/terraform')

    # NOTE the correct way to deal with the preexisting gateway lambda function
    # is to `terraform import` it and reconfigure its role alongside everything else.
    # Lambda import is currently broken in Terraform 0.11.8.
    # I have raised a bug (https://github.com/terraform-providers/terraform-provider-aws/issues/5742)
    # on this, once/if that is fixed we should do this part with terraform and not python/awscli.

    subprocess.check_call(
        [
            'terraform', 'apply' if install else 'destroy', '-auto-approve',
            '-var', 'region={0}'.format(region),
            '-var', 'jazz_aws_accountid={0}'.format(accountId),
            '-var', 'env_prefix={0}'.format(envPrefix),
            '-var', 'gateway_func_arn={0}'.format(terraformBugWorkaround.getFunctionArn(envPrefix + "-" +
                                                  gatewayFunctionName)),
            '-var', 'previous_role_arn={0}'.format(terraformBugWorkaround.getFunctionRole(envPrefix + "-" +
                                                   gatewayFunctionName))
        ],
        cwd='extensions/apigee/terraform')


def terraformStateSanityCheck():
    print(colors.OKBLUE +
          'Making sure you have not deleted the Terraform .tfstate file...' +
          colors.ENDC)
    if not os.path.isfile('extensions/apigee/terraform/terraform.tfstate'):
        print(colors.FAIL +
              'Cannot find the Terraform .tfstate file! No uninstall possible'
              + colors.ENDC)


def getTerraformOutputVar(varname):
    try:
        return subprocess.check_output(
            ['terraform', 'output', varname],
            cwd='extensions/apigee/terraform', encoding='UTF-8').rstrip()
    except subprocess.CalledProcessError:
        print("Failed getting output variable {0} from terraform!".format(varname))
        sys.exit()


# We ought to depend on boto3 for this stuff, not awscli
def getAWSAccountID():
    print(colors.OKBLUE +
          'Obtaining AWS account ID using configured credentials\n' +
          colors.ENDC)
    return subprocess.check_output([
        'aws', 'sts', 'get-caller-identity', '--output', 'text', '--query', 'Account'
    ], encoding='UTF-8').rstrip()


def prepare_apigee_json(apigeeHost, apigeeCredId, apigeeProdEnv, apigeeDevEnv,
                        apigeeSvcProdHost, apigeeSvcDevHost, apigeeOrg):
    apigee_json = {
        "API_ENDPOINTS": {
          "DEV": {
            "MGMT_ENV": apigeeDevEnv,
            "MGMT_HOST": apigeeHost,
            "MGMT_ORG": apigeeOrg,
            "SERVICE_HOSTNAME": apigeeSvcDevHost
          },
          "PROD": {
            "MGMT_ENV": apigeeProdEnv,
            "MGMT_HOST": apigeeHost,
            "MGMT_ORG": apigeeOrg,
            "SERVICE_HOSTNAME": apigeeSvcProdHost
          }
        },
        "APIGEE_CRED_ID": apigeeCredId,
        "BUILD_VERSION": "1.0",
        "ENABLE_APIGEE": True,
        "USE_SECURE": False
    }
    return apigee_json
