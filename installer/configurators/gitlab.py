import re
from .common import get_tfvars_file, replace_tfvars


def configure_gitlab(gitlabip, gitlabuserpass):
    # TODO having to explicitly disable each other SCM type by name here is not elegant
    replace_tfvars('scmbb', 'false', get_tfvars_file(), False)
    replace_tfvars("scmgitlab", "true", get_tfvars_file(), False)
    replace_tfvars('scm_type', 'gitlab', get_tfvars_file())
    replace_tfvars('scm_pathext', '/', get_tfvars_file())

    replace_tfvars('scm_publicip', gitlabip, get_tfvars_file())
    replace_tfvars('scm_elb', gitlabip, get_tfvars_file())

    scm_username = re.sub('[^a-zA-Z0-9_-]', '-', str(gitlabuserpass[0]))
    scm_passwd = str(gitlabuserpass[1])
    replace_tfvars('scm_username', scm_username, get_tfvars_file())
    replace_tfvars('scm_passwd', scm_passwd, get_tfvars_file())
