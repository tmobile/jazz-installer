#!/usr/bin/env python2
import sys
import subprocess
import argparse
import os.path
import terraformBugWorkaround
from apigeeinstaller.init_apigee_install import install_proxy
from git_config import replace_config, revert_config


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


def main():
    # TODO replace argparse stuff and manual arg validation checking with Click once main installer rewrite is done
    mainParser = argparse.ArgumentParser()
    mainParser.description = ('Installs the Apigee extension for the Jazz Serverless Development Platform '
                              '(https://github.com/tmobile/jazz)')
    subparsers = mainParser.add_subparsers(help='Installation scenarios', dest='command')

    subparsers.add_parser('install', help='Install feature extension').set_defaults(func=install)
    subparsers.add_parser('uninstall', help='Uninstall feature extension').set_defaults(func=uninstall)

    mainParser.add_argument(
        '--aws-region',
        help='Specify the region where your Jazz installation lives.'
    )
    mainParser.add_argument(
        '--jazz-stackprefix',
        help='Specify the stackprefix of your existing Jazz installation (e.g. myjazz), \
              your existing config will be imported'
    )

    mainParser.add_argument(
        '--scm-repo',
        help='Specify the scm repo url'
    )

    mainParser.add_argument(
        '--scm-username',
        help='Specify the scm username'
    )

    mainParser.add_argument(
        '--scm-password',
        help='Specify the scm password'
    )

    mainParser.add_argument(
        '--scm-pathext',
        help='Specify the scm repo path ext (Use "scm" for bitbucket)'
    )

    mainParser.add_argument("apigee_host", help="Url of the Apigee host (e.g. https://my-apigee-host)")
    mainParser.add_argument("apigee_org", help="Name of the Apigee org you wish to use")
    mainParser.add_argument("apigee_env", help="Name of the Apigee env you wish to use")
    mainParser.add_argument("apigee_svc_host", help="Url of the service API host (e.g. jazz.api.t-mobile.com)")
    mainParser.add_argument("apigee_username", help="Username to use when accessing Apigee")
    mainParser.add_argument("apigee_password", help="Password to use when accessing Apigee")

    args = mainParser.parse_args()
    args.func(args)


def install(args):
    print(
        colors.OKGREEN +
        "\nThis will install {0} functionality into your Jazz deployment.\n".format(featureName)
        + colors.ENDC)
    print(
        colors.OKGREEN +
        "This installer will use whatever AWS credentials you have configured by running 'aws configure'.\n"
        + colors.ENDC)
    print(
        colors.WARNING +
        "Please make sure you are using the same AWS credentials you used to install your Jazz deployment\n\n"
        + colors.ENDC)

    collect_userinputs(args)

    # Run terraform first, as we need it's output
    runTerraform(getRegion(args), getAWSAccountID(), getEnvPrefix(args), True)
    # TODO remove this entire module when the terraform bug is fixed
    print(
        colors.OKBLUE + 'Linking new role to existing gateway function' + colors.ENDC)
    terraformBugWorkaround.linkNewRoleToExistingFunctionWithCLI(getEnvPrefix(args) + "-" + gatewayFunctionName)

    install_proxy(
        getTerraformOutputVar("apigee-lambda-user-secret-key"),
        getTerraformOutputVar("apigee-lambda-user-id"),
        getTerraformOutputVar("apigee-lambda-gateway-func-arn"),
        args.apigee_host,
        args.apigee_org,
        args.apigee_env,
        "1.0",
        args.apigee_username,
        args.apigee_password
    )

    replace_config(
        args.apigee_host,
        "ApigeeforJazz",
        args.apigee_env,
        args.apigee_svc_host,
        args.apigee_org,
        args.scm_repo,
        args.scm_username,
        args.scm_password,
        args.scm_pathext
    )
    print(
        colors.OKBLUE +
        "Please make sure to add the credential ID as 'ApigeeforJazz' \
         with the apigee username and password in the Jenkins\n\n"
        + colors.ENDC)


def uninstall(args):
    print(
        colors.OKGREEN +
        "\nThis will remove {0} functionality from your Jazz deployment.\n".format(featureName)
        + colors.ENDC)
    collect_userinputs(args)
    terraformStateSanityCheck()

    # TODO remove this entire module when the terraform bug is fixed
    print(
        colors.OKBLUE + 'Restoring old role to gateway function' + colors.ENDC)

    # Restore old role first, before we destroy the Terraform resources
    terraformBugWorkaround.restoreOldRoleToExistingFunctionWithCLI(getEnvPrefix(args) + "-" + gatewayFunctionName)

    runTerraform(getRegion(args), getAWSAccountID(), getEnvPrefix(args), False)
    revert_config(
        args.scm_repo,
        args.scm_username,
        args.scm_password,
        args.scm_pathext
    )


def runTerraform(region, accountId, envPrefix, install):
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='./terraform')

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
        cwd='./terraform')


def terraformStateSanityCheck():
    print(colors.OKBLUE +
          'Making sure you have not deleted the Terraform .tfstate file...' +
          colors.ENDC)
    if not os.path.isfile('./terraform/terraform.tfstate'):
        print(colors.FAIL +
              'Cannot find the Terraform .tfstate file! No uninstall possible'
              + colors.ENDC)


def getTerraformOutputVar(varname):
    try:
        return subprocess.check_output(
            ['terraform', 'output', varname],
            cwd='./terraform')
    except subprocess.CalledProcessError:
            print("Failed getting output variable {0} from terraform!".format(varname))
            sys.exit()


def getRegion(args):
    if not args.aws_region:
        region = raw_input(
            "Please enter the region where your Jazz installation lives: ")

        if region is "":
            print("No region entered, defaulting to 'us-east-1'")
            region = "us-east-1"
        return region
    else:
        return args.aws_region


# TODO Obviously it would be better if we could somehow automatically infer the
# env prefix that the user used to install Jazz proper, but I don't see a
# robust way to do that yet, so KISS is a better principal to follow here.
# Also, there are no programmatic side effects if they happen to enter a
# different prefix.
def getEnvPrefix(args):
    if not args.jazz_stackprefix:
        return raw_input(
            "Please enter the environment prefix you used for your Jazz install: ")
    else:
        return args.jazz_stackprefix


# We ought to depend on boto3 for this stuff, not awscli
def getAWSAccountID():
    print(colors.OKBLUE +
          'Obtaining AWS account ID using configured credentials\n' +
          colors.ENDC)
    return subprocess.check_output([
        'aws', 'sts', 'get-caller-identity', '--output', 'text', '--query', 'Account'
    ]).rstrip()


def collect_userinputs(args):
    if not args.scm_repo:
        args.scm_repo = raw_input("Please enter the SCM Repo: ")

    if not args.scm_username:
        args.scm_username = raw_input("Please enter the SCM Username: ")

    if not args.scm_password:
        args.scm_password = raw_input("Please enter the SCM Password: ")

    if not args.scm_pathext:
        args.scm_pathext = raw_input("Please enter the SCM Pathext (Use \"/scm\" for bitbucket): ") or "/"

    return args


main()
