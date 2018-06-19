if [ -f /etc/lsb-release ]; then
  curl -o chefdk.deb https://packages.chef.io/files/stable/chefdk/2.4.17/ubuntu/16.04/chefdk_2.4.17-1_amd64.deb
  dpkg -i chefdk.deb
elif [ -f /etc/redhat-release ]; then
  curl -o chefdk.rpm https://packages.chef.io/files/stable/chefdk/1.6.11/el/7/chefdk-1.6.11-1.el7.x86_64.rpm
  rpm -Kvv --nosignature chefdk.rpm
  rpm -ivh chefdk.rpm
else echo "We could not detect your OS type, cannot install chefdk!"
fi
