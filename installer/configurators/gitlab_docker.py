from time import sleep
from installer.helpers.processwrap import call, check_output, check_call
from installer.configurators.common import passwd_generator
from installer.configurators.gitlab_personalaccesstoken import generate_personal_access_token
import gitlab


# TODO ECS will obviate this entire file
def tidy_if_needed():
    # Stop existing docker image, if it doesn't exist these will fail but we don't care.
    call([
        'docker',
        'stop',
        'gitlab'
    ])
    call([
        'docker',
        'rm',
        'gitlab'
    ])

    call([
        'sudo',
        'rm',
        '-rf',
        '/srv/gitlab'
    ])


def launch_dockerized_gitlab():
    dockerhub = 'gitlab'
    dockertag = 'latest'
    passwd = passwd_generator()

    # Cleanup old install
    tidy_if_needed()

    ip = check_output([
        'curl',
        '-sL',
        'http://169.254.169.254/latest/meta-data/public-ipv4'
    ]).decode()

    check_call([
        'docker',
        'run',
        '-d',
        '-h',
        ip,
        '--name',
        'gitlab',
        '-p',
        '443:443',
        '-p',
        '80:80',
        '-p',
        '2201:22',
        '--restart',
        'always',
        '-v',
        '/srv/gitlab/config:/etc/gitlab',
        '-v',
        '/srv/gitlab/logs:/var/log/gitlab',
        '-v',
        '/srv/gitlab/data:/var/opt/gitlab',
        '-e',
        "GITLAB_OMNIBUS_CONFIG=gitlab_rails['initial_root_password'] = '{0}'; \
        gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8']; ".format(passwd),
        '{0}/gitlab-ce:{1}'.format(dockerhub, dockertag)
    ])

    # Wait for container to start
    # TODO consider a status check here rather than a fixed sleep, which is sloppy
    sleep(120)

    token = generate_personal_access_token('mytoken', passwd)

    gl = gitlab.Gitlab("http://localhost", api_version=4, private_token=token)

    group = gl.groups.create({'name': 'SLF', 'path': 'slf', 'description': 'Jazz framework, templates and services'})

    return {
        'gitlab_ip': ip,
        'gitlab_userpass': ['root', passwd],
        'gitlab_slfid': group.id,
        'gitlab_token': token
    }
