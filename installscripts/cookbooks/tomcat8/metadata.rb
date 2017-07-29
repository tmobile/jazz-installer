name             'tomcat8'
maintainer       'Brandon Sharitt'
maintainer_email 'bsharitt@franklinamerican.com'
license          'Apache 2.0'
description      'Installs/Configures tomcat8'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
issues_url       'https://github.com/bsharitt/tomcat8/issues' if respond_to?(:issues_url)
source_url       'https://github.com/bsharitt/tomcat8' if respond_to?(:source_url)
supports         'ubuntu'
depends          'java'
