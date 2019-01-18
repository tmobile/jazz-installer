import sys
import subprocess
import json
from collections import OrderedDict


def main():
    output = OrderedDict()
    key_common_list = OrderedDict([
                        ("jenkinselb", "Jenkins ELB"), ("jenkinsuser", "Jenkins Username"),
                        ("jenkinspasswd", "Jenkins Password"), ("jazzhome", "Jazz Home"),
                        ("jazzusername", "Jazz Admin Username"), ("jazzpassword", "Jazz Admin Password"),
                        ("region", "Region"), ("apiendpoint", "Jazz API Endpoint")
                        ])
    output = generateDict(key_common_list, output)

    if getTerraformOutputVar("codeq") == "1":
        key_codeq_list = OrderedDict([
                           ("sonarhome", "Sonar Home"), ("sonarusername", "Sonar Username"),
                           ("sonarpasswd", "Sonar Password")
                           ])
        output = generateDict(key_codeq_list, output)

    if getTerraformOutputVar("scmbb") == "1":
        key_bb_list = OrderedDict([
                        ("scmelb", "Bitbucket ELB"), ("scmusername", "Bitbucket Username"),
                        ("scmpasswd", "Bitbucket Password")
                        ])
        output = generateDict(key_bb_list, output)

    if getTerraformOutputVar("scmgitlab") == "1":
        key_gitlab_list = OrderedDict([
                            ("scmelb", "Gitlab Home"), ("scmusername", "Gitlab Username"),
                            ("scmpasswd", "Gitlab Password")
                            ])
        output = generateDict(key_gitlab_list, output)

    with open("stack_details.json", 'w+') as file:
        file.write(json.dumps(output, indent=4))


def generateDict(outputkeys, output):
    for opkey, key in outputkeys.items():
        output.update({key: getTerraformOutputVar(opkey)})
    return output


def getTerraformOutputVar(varname):
    try:
        return subprocess.check_output(['terraform', 'output', varname], cwd='./').strip()
    except subprocess.CalledProcessError:
            print("Failed getting output variable {0} from terraform!".format(varname))
            sys.exit()


main()
