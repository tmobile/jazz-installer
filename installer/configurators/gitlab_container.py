from .common import get_tfvars_file, replace_tfvars


def configure_gitlab_container():
    # TODO having to explicitly disable each other SCM type by name here is not elegant
    replace_tfvars('scmbb', 'false', get_tfvars_file(), False)
    replace_tfvars("scmgitlab", "true", get_tfvars_file(), False)
    replace_tfvars('scm_type', 'gitlab', get_tfvars_file())
    replace_tfvars('scm_pathext', '/', get_tfvars_file())
