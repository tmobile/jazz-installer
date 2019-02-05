name 'jazz'
default_source :supermarket
cookbook 'maven', '~> 5.1.0'
cookbook 'nodejs', '~> 5.0.0'
cookbook 'cloudcli', '~> 1.2.0'
cookbook 'jenkins', path: './jenkins'
run_list 'jenkins::setupjenkins', 'jenkins::sonarqube-scanner', 'jenkins::installgolang', 'jenkins::installpython3'
