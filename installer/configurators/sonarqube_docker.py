from time import sleep
from installer.helpers.processwrap import call, check_output, check_call
from installer.configurators.common import passwd_generator


# TODO ECS will obviate this entire file
def tidy_if_needed():
    # Stop existing docker image, if it doesn't exist these will fail but we don't care.
    call([
        'docker',
        'stop',
        'sonarqube'
    ])
    call([
        'docker',
        'rm',
        'sonarqube'
    ])


def launch_dockerized_sonarqube():
    dockerhub = 'sonarqube'
    dockertag = 'latest'
    passwd = passwd_generator()

    # Cleanup old install
    tidy_if_needed()

    check_call([
        'docker',
        'run',
        '-d',
        '--name',
        'sonarqube',
        '-p',
        '9000:9000',
        '-p',
        '9092:9092',
        '-v',
        'sonarqube-temp:/opt/sonarqube/temp',
        '{0}:{1}'.format(dockerhub, dockertag)
    ])

    # Wait for container to start
    # TODO consider a status check here rather than a fixed sleep, which is sloppy
    sleep(10)

    check_call([
        'docker',
        'exec',
        '-i',
        'sonarqube',
        'bash',
        '-c',
        (
            '"wget -O extensions/plugins/sonar-dependency-check-plugin-1.1.0.jar',
            'https://bintray.com/stevespringett/owasp/download_file',
            '?file_path=org%2Fsonarsource%2Fowasp%2Fsonar-dependency-check-plugin',
            '%2F1.1.0%2Fsonar-dependency-check-plugin-1.1.0.jar ',
            '&& chown sonarqube:sonarqube extensions/plugins/sonar-dependency-check-plugin-1.1.0.jar"'
         )
    ])

    ip = check_output([
        'curl',
        '-sL',
        'http://169.254.169.254/latest/meta-data/public-ipv4'
    ]).decode()

    check_call([
        'curl',
        '-u',
        'admin:admin',
        '-X',
        'POST',
        '-F',
        '"name=JazzProfile"',
        '-F',
        '"language=java"',
        'http://{0}:9000/api/qualityprofiles/create'.format(ip)

    ])

    check_call([
        'curl',
        '-u',
        'admin:admin',
        '-X',
        'POST',
        '-F',
        '"name=JazzProfile"',
        '-F',
        '"language=js"',
        'http://{0}:9000/api/qualityprofiles/create'.format(ip)

    ])

    check_call([
        'curl',
        '-u',
        'admin:admin',
        '-X',
        'POST',
        '-F',
        '"name=JazzProfile"',
        '-F',
        '"language=py"',
        'http://{0}:9000/api/qualityprofiles/create'.format(ip)

    ])

    check_call([
        'curl',
        '-u',
        'admin:admin',
        '-X',
        'POST',
        '-F',
        '"login=admin"',
        '-F',
        '"password={0}"'.format(passwd),
        '-F',
        '"previousPassword=admin"',
        'http://{0}:9000/api/users/change_password'.format(ip)

    ])

    check_call([
        'curl',
        '-u',
        'admin:{0}'.format(passwd),
        '-X',
        'POST',
        'http://{0}:9000/api/system/restart'.format(ip)

    ])

    return {
        'sonar_server_elb': '{0}:9000'.format(ip),
        'sonar_userpass': ['admin', passwd],
        'sonar_publicip': ip
    }
