from installer.configurators.gitlab_docker import launch_dockerized_gitlab
from .common import get_tfvars_file, replace_tfvars


def update_gitlab_terraform(gitlabip, gitlabuserpass, gitlabslfid, gitlabtoken):
    # TODO having to explicitly disable each other SCM type by name here is not elegant
    replace_tfvars('scmbb', 'false', get_tfvars_file(), False)
    replace_tfvars('scmgitlab', 'false', get_tfvars_file(), False)
    replace_tfvars('scm_type', 'gitlab', get_tfvars_file())
    replace_tfvars('scm_pathext', '/', get_tfvars_file())

    replace_tfvars('scm_slfid', gitlabslfid, get_tfvars_file())
    replace_tfvars('scm_privatetoken', gitlabtoken, get_tfvars_file())
    replace_tfvars('scm_publicip', gitlabip, get_tfvars_file())
    replace_tfvars('scm_elb', gitlabip, get_tfvars_file())
    replace_tfvars('scm_username', gitlabuserpass[0], get_tfvars_file())
    replace_tfvars('scm_passwd', gitlabuserpass[1], get_tfvars_file())


def configure_gitlab_docker():
    """
        Launch a dockerized Sonar server.
    """
    res = launch_dockerized_gitlab()
    # TODO old version passed in password and root account email, don't think they're needed but check
    update_gitlab_terraform(res['gitlab_ip'], res['gitlab_userpass'], res['gitlab_slfid'], res['gitlab_token'])
