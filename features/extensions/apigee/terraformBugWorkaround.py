import json
import subprocess
import retrying
import os
import sys


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


terraformNewGatewayRoleOutput = "apigee-lambda-gateway-role-arn"
terraformPreviousRoleOutput = "previous-role-arn"
featureName = "Apigee"
# The lambda function created has the format of ENVPREFIX-jazz-apigee-proxy-aws-STAGE
gatewayFunctionName = "jazz-apigee-proxy-aws-prod"
terraformGatewayResource = "aws_lambda_function.jazz-apigee-proxy"


def runTerraform(region, envPrefix, install):

    # NOTE the correct way to deal with the preexisting gateway lambda function
    # is to `terraform import` it and reconfigure its role alongside everything else.
    # Lambda import is currently broken in Terraform 0.11.8.
    # I have raised a bug (https://github.com/terraform-providers/terraform-provider-aws/issues/5742)
    # on this, once/if that is fixed we should do this part with terraform and not python/awscli.
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='extensions/apigee/terraform')
    subprocess.check_call(
        [
            'terraform', 'apply' if install else 'destroy', '-auto-approve',
            '-var', 'region={0}'.format(region),
            '-var', 'jazz_aws_accountid={0}'.format(getAWSAccountID()),
            '-var', 'env_prefix={0}'.format(envPrefix),
            '-var', 'gateway_func_arn={0}'.format(getFunctionArn(envPrefix + "-" +
                                                  gatewayFunctionName)),
            '-var', 'previous_role_arn={0}'.format(getFunctionRole(envPrefix + "-" +
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


# Replaces function's role with one created by Terraform
# Amazon needs a few seconds to replicate the new role through all regionsself.
# So, the fix here is to wait a few seconds before creating the Lambda function.
# Ref: https://tinyurl.com/ybylpzfw and https://tinyurl.com/ya9gh8eh
@retrying.retry(wait_exponential_multiplier=1000, wait_exponential_max=10000)
def linkNewRoleToExistingFunctionWithCLI(functionName):
    updateFunctionRole(functionName, getRoleArnFromTerraform())


# Restores function's original role to what it was before
def restoreOldRoleToExistingFunctionWithCLI(functionName):
    updateFunctionRole(functionName, getPreviousRoleArnFromTerraform())


def getFunctionArn(gatewayFuncName):
    return getFunctionConfig(gatewayFuncName)['FunctionArn']


def getFunctionRole(gatewayFuncName):
    return getFunctionConfig(gatewayFuncName)['Role']


def getRoleArnFromTerraform():
    return getTerraformOutput(terraformNewGatewayRoleOutput)


def getPreviousRoleArnFromTerraform():
    return getTerraformOutput(terraformPreviousRoleOutput)


def getTerraformOutput(outputVarName):
    return subprocess.check_output(
        [
            'terraform',
            'output',
            outputVarName
        ],
        cwd='extensions/apigee/terraform', encoding='UTF-8').rstrip()


def updateFunctionRole(functionName, roleArn):
    subprocess.check_call([
        'aws',
        'lambda',
        'update-function-configuration',
        '--function-name',
        functionName,
        '--role',
        str(roleArn)
    ])


def getFunctionConfig(gatewayFuncName):
    return json.loads(subprocess.check_output([
        'aws',
        'lambda',
        'get-function-configuration',
        '--function-name',
        gatewayFuncName,
        '--output',
        'json'
    ], encoding='UTF-8').rstrip())


# We ought to depend on boto3 for this stuff, not awscli
def getAWSAccountID():
    print(colors.OKBLUE +
          'Obtaining AWS account ID using configured credentials\n' +
          colors.ENDC)
    return subprocess.check_output([
        'aws', 'sts', 'get-caller-identity', '--output', 'text', '--query', 'Account'
    ], encoding='UTF-8').rstrip()
