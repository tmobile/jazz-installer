name "jazz"
default_source :supermarket
cookbook 'poise-python', '~> 1.7.0'
cookbook 'jenkins', path: 'cookbooks/jenkins'
cookbook 'git', path: 'cookbooks/git'
cookbook 'maven', path: 'cookbooks/maven'
cookbook 'npm', path: 'cookbooks/npm'
cookbook 'aws', path: 'cookbooks/aws'
run_list "git", "maven", "npm", "aws", "jenkins::configurejenkins"
