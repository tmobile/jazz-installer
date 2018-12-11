import json
import subprocess
import retrying


terraformNewGatewayRoleOutput = "apigee-lambda-gateway-role-arn"
terraformPreviousRoleOutput = "previous-role-arn"


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
        cwd='./terraform').rstrip()


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
    ]).rstrip())
