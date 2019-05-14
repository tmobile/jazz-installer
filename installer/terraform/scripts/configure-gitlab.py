from gitlab_personalaccesstoken import generate_personal_access_token
from terraform_external_data import terraform_external_data

import gitlab


@terraform_external_data
def get_gitlab_group(query):
    token = generate_personal_access_token('mytoken', query['passwd'], query['gitlab_ip'])

    gl = gitlab.Gitlab('http://{0}'.format(query['gitlab_ip']), api_version=4, private_token=token)

    slfGroup = gl.groups.create({'name': 'SLF', 'path': 'slf', 'description': 'Jazz framework, templates and services'})
    gl.groups.create({'name': 'CAS', 'path': 'cas', 'description': 'User created services repository'})

    # Update the username from the `root` user to scm_username, because for some
    # reason downstream stuff needs it.
    # TODO Downstream stuff should only need the access token, investigate if user
    # creds can be dropped after this point in favor of the PAT
    rootUser = gl.users.list(username='root')[0]
    rootUser.username = query['scm_username']
    rootUser.save()

    return {
        'gitlab_slfid': str(slfGroup.id),
        'gitlab_token': str(token)
    }


if __name__ == '__main__':
    get_gitlab_group()
