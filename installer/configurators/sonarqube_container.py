from .common import get_tfvars_file, replace_tfvars, passwd_generator


def configure_sonarqube_container():
    """
        Configure a containerized Sonar server.
    """
    replace_tfvars("dockerizedSonarqube", "true", get_tfvars_file(), False)
    replace_tfvars('sonar_username', "admin", get_tfvars_file())
    replace_tfvars('sonar_passwd', passwd_generator(), get_tfvars_file())
    replace_tfvars('codequality_type', 'sonarqube', get_tfvars_file())
    replace_tfvars('codeq', 1, get_tfvars_file())
