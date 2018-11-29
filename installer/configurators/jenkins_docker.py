from time import sleep
from installer.configurators.common import passwd_generator
from installer.helpers.processwrap import call, check_output, check_call


# TODO ECS will obviate this entire file
def tidy_if_needed():
    # Stop existing docker image, if it doesn't exist these will fail but we don't care.
    call([
        'docker',
        'stop',
        'jenkins-server'
    ])
    call([
        'docker',
        'rm',
        'jenkins-server'
    ])

    call([
        'docker',
        'volume',
        'rm',
        'jenkins-volume'
    ])


def launch_dockerized_jenkins():
    dockerhub = 'jazzserverless'
    dockertag = '1.0.0'
    passwd = passwd_generator()

    # Cleanup old install
    tidy_if_needed()

    check_call([
        'docker',
        'pull',
        '{0}/jazzoss-jenkins:{1}'.format(dockerhub, dockertag)
    ])

    check_call([
        'docker',
        'volume',
        'create',
        'jenkins-volume'
    ])

    check_call([
        'docker',
        'run',
        '-d',
        '--name',
        'jenkins-server',
        '-p',
        '8081:8080',
        '-v',
        'jenkins-volume:/var/jenkins_home',
        '-e',
        'JENKINS_USER="admin"',
        '-e',
        'JENKINS_PASS={0}'.format(passwd),
        '{0}/jazzoss-jenkins:{1}'.format(dockerhub, dockertag)
    ])

    # Wait for container to start
    # TODO consider a status check here rather than a fixed sleep, which is sloppy
    sleep(60)

    ip = check_output([
        'curl',
        '-sL',
        'http://169.254.169.254/latest/meta-data/public-ipv4'
    ]).decode()

    mac = check_output([
        'curl',
        '-sL',
        'http://169.254.169.254/latest/meta-data/network/interfaces/macs'
    ]).decode()

    secgroup = check_output([
        'curl',
        '-sL',
        'http://169.254.169.254/latest/meta-data/network/interfaces/macs/{0}/security-group-ids'.format(mac)
    ]).decode()

    subnet = check_output([
        'curl',
        '-sL',
        'http://169.254.169.254/latest/meta-data/network/interfaces/macs/{0}/subnet-id'.format(mac)
    ]).decode()

    return {
        'jenkins_elb': '{0}:8081'.format(ip),
        'jenkins_userpass': ['admin', passwd],
        'jenkins_publicip': ip,
        'jenkins_sshuser': 'root',
        'jenkins_sshport': '2200',
        'jenkins_secgroup': secgroup,
        'jenkins_subnet': subnet
    }
