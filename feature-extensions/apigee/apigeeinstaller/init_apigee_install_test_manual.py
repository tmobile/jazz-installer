import init_apigee_install
import os
from zipfile import ZipFile

apigeeUser = 'xxxx'
apigeePassword = 'xxxx'


def test_get_basic_auth():
    username = 'testuser'
    password = 'testpassword'
    expected = 'Basic dGVzdHVzZXI6dGVzdHBhc3N3b3Jk'
    actual = init_apigee_install.get_basic_auth(username, password)
    assert(actual == expected)
    print 'Passed'


def test_get_current_deployed_version():
    expected = '1'
    actual = init_apigee_install.get_current_deployed_version(
        'https://api.enterprise.apigee.com',
        'tmobilea',
        'sb02',
        'InitializeRequest',
        apigeeUser,
        apigeePassword)
    assert(actual == expected)
    print 'Passed'


def test_is_api_deployed():
    expected = True
    actual = init_apigee_install.is_api_deployed(
        'https://api.enterprise.apigee.com',
        'tmobilea',
        'sb02',
        'InitializeRequest',
        '1',
        apigeeUser,
        apigeePassword)
    assert(actual == expected)
    print 'Passed'


def test_zip_bundle():
    name = 'DataEncryption'
    path = "./test/%s" % name
    build = 'Build.1.2.3'
    sFiles = [
        os.path.join(dir, addFile)
        for dir, dirList, fileList in os.walk(os.path.join(path, 'sharedflowbundle'))
        for addFile in fileList]
    expected = [sourcePath[len(path) + 1:len(sourcePath)].replace('\\', '/')
                for sourcePath in sFiles]
    created = init_apigee_install.zip_bundle(path, name, build)
    actualFiles = []
    with ZipFile(created, 'r') as actual:
        for info in actual.infolist():
            assert(info.filename in expected)
            actualFiles.append(info.filename)
    for f in expected:
        assert(f in actualFiles)
    print 'Passed'


def test_import_item():
    zFile = './test/DataEncryption/DataEncryption-Build.1.2.3.zip'
    actual = init_apigee_install.import_item(
        zFile,
        'https://api.enterprise.apigee.com',
        'tmobilea',
        'DataEncryption',
        'sharedflows',
        apigeeUser,
        apigeePassword)
    print "actual %s" % actual
    assert(actual == '16')
    print 'Passed'


def test_create_kvm():
    secretKey = 'alskduf109341243'
    reg = '3'
    lambdaARN = '1231lkjlkj123'
    org = 'tmobilea'
    env = 'sb02'
    init_apigee_install.create_kvm(
        secretKey,
        reg,
        lambdaARN,
        'https://api.enterprise.apigee.com',
        org,
        env,
        apigeeUser,
        apigeePassword)


def test_deploy():
    init_apigee_install.deploy(
        'https://api.enterprise.apigee.com',
        'tmobilea',
        'sb02',
        'DataEncryption',
        '8',
        apigeeUser,
        apigeePassword)


def test_undeploy():
    init_apigee_install.undeploy(
        'https://api.enterprise.apigee.com',
        'tmobilea',
        'sb02',
        'DataEncryption',
        '8',
        apigeeUser,
        apigeePassword)


def test_deploy_api():
    actual = init_apigee_install.deploy_api(
        'https://api.enterprise.apigee.com',
        'tmobilea',
        'sb02',
        'TestNumberManagement',
        '1',
        apigeeUser,
        apigeePassword)
    assert(actual)
    print 'Passed'


def test_get_content():
    testFile = 'Common-Jazz.zip'
    url = 'https://github.com/michmerr/jazz-content'
    branch = 'apigee-extension'

    if (os.path.exists(testFile)):
        os.unlink(testFile)

    init_apigee_install.get_content(testFile, url, branch)
    assert(os.path.exists(testFile))
    print ('test_get_content Passed')


# test_get_basic_auth()
# test_get_current_deployed_version()
# test_is_api_deployed()
# test_stamp_build()
# test_zip_bundle()
# test_import_item()
# test_create_kvm()
# test_undeploy()
# test_deploy()
# test_deploy_api()
# test_get_content()
