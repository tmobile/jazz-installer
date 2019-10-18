import json
import subprocess
import retrying


from utils.helper import colors


featureName = "Tvault"


def runTerraform(region, envPrefix, jazzPassword, install):

    # NOTE the correct way to deal with the preexisting gateway lambda function
    # is to `terraform import` it and reconfigure its role alongside everything else.
    # Lambda import is currently broken in Terraform 0.11.8.
    # I have raised a bug (https://github.com/terraform-providers/terraform-provider-aws/issues/5742)
    # on this, once/if that is fixed we should do this part with terraform and not python/awscli.
    print(
        colors.OKBLUE + 'Initializing and running Terraform.\n' + colors.ENDC)
    subprocess.check_call(['terraform', 'init'], cwd='extensions/tvault/terraform')
    subprocess.check_call(
        [
            'terraform', 'apply' if install else 'destroy', '-auto-approve',
            '-var', 'region={0}'.format(region),
            '-var', 'env_prefix={0}'.format(envPrefix),
            '-var', 'jazzPassword={0}'.format(jazzPassword)
        ],
        cwd='extensions/tvault/terraform')


def getTerraformOutput(outputVarName):
    return subprocess.check_output(
        [
            'terraform',
            'output',
            outputVarName
        ],
        cwd='extensions/tvault/terraform', encoding='UTF-8').rstrip()
