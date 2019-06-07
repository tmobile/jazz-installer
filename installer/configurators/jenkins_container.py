from installer.configurators.common import get_tfvars_file, replace_tfvars, passwd_generator


def configure_jenkins_container(existing_vpc_id, vpc_cidr, ecs_range):
    """
        Launch a containerized Jenkins server.
    """
    if existing_vpc_id:
        replace_tfvars('existing_vpc_ecs', existing_vpc_id, get_tfvars_file())
    else:
        replace_tfvars("autovpc", "true", get_tfvars_file(), False)
        replace_tfvars("vpc_cidr_block", vpc_cidr, get_tfvars_file())

    replace_tfvars('network_range', ecs_range, get_tfvars_file())
    replace_tfvars('jenkinsuser', "admin", get_tfvars_file())
    replace_tfvars('jenkinspasswd', passwd_generator(), get_tfvars_file())
