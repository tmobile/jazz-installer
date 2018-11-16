import sys
import subprocess
import json
from collections import OrderedDict


def main():
    output = OrderedDict()
    key_common_list = OrderedDict([
                        ("op-jenkinselb", "Jenkins ELB"), ("op-jenkinsuser", "Jenkins Username"),
                        ("op-jenkinspasswd", "Jenkins Password"), ("op-jazzhome", "Jazz Home"),
                        ("op-jazzusername", "Jazz Admin Username"), ("op-jazzpassword", "Jazz Admin Password"),
                        ("op-region", "Region"), ("op-apiendpoint", "Jazz API Endpoint")
                        ])
    output = generateDict(key_common_list, output)

    if getTerraformOutputVar("op-codeq") == "1":
        key_codeq_list = OrderedDict([
                           ("op-sonarhome", "Sonar Home"), ("op-sonarusername", "Sonar Username"),
                           ("op-sonarpasswd", "Sonar Password")
                           ])
        output = generateDict(key_codeq_list, output)

    if getTerraformOutputVar("op-scmbb") == "1":
        key_bb_list = OrderedDict([
                        ("op-scmelb", "Bitbucket ELB"), ("op-scmusername", "Bitbucket Username"),
                        ("op-scmpasswd", "Bitbucket Password")
                        ])
        output = generateDict(key_bb_list, output)

    if getTerraformOutputVar("op-scmgitlab") == "1":
        key_gitlab_list = OrderedDict([
                            ("op-scmelb", "Gitlab Home"), ("op-scmusername", "Gitlab Username"),
                            ("op-scmpasswd", "Gitlab Password")
                            ])
        output = generateDict(key_gitlab_list, output)

    with open("stack_details.json", 'w+') as file:
        file.write(json.dumps(output, indent=4))


def generateDict(outputkeys, output):
    for opkey, key in outputkeys.items():
        output = setDict(output, key, opkey)
    return output


def setDict(dict_toappend, key, opkey):
    dict_toappend[key] = getTerraformOutputVar(opkey)
    return dict_toappend


def getTerraformOutputVar(varname):
    try:
        return subprocess.check_output(['terraform', 'output', varname], cwd='./').strip()
    except subprocess.CalledProcessError:
            print("Failed getting output variable {0} from terraform!".format(varname))
            sys.exit()


main()
