from gitlab_personalaccesstoken import generate_personal_access_token
from terraform_external_data import terraform_external_data

import gitlab


@terraform_external_data
def get_gitlab_group(query):
    token = generate_personal_access_token('mytoken', query['passwd'], query['gitlab-ip'])

    gl = gitlab.Gitlab('http://'.format(query['gitlab_ip']), api_version=4, private_token=token)

    group = gl.groups.create({'name': 'SLF', 'path': 'slf', 'description': 'Jazz framework, templates and services'})

    return {
        'gitlab_slfid': str(group.id),
        'gitlab_token': str(token)
    }


if __name__ == '__main__':
    get_gitlab_group()
