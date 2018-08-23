if [ -f /etc/lsb-release ]; then
    curl -o chefdk.deb https://packages.chef.io/files/stable/chefdk/3.0.36/ubuntu/16.04/chefdk_3.0.36-1_amd64.deb
    dpkg -i chefdk.deb
elif [ -f /etc/redhat-release ]; then
    curl -o chefdk.rpm https://packages.chef.io/files/stable/chefdk/3.0.36/el/7/chefdk-3.0.36-1.el7.x86_64.rpm
    rpm -Kvv --nosignature chefdk.rpm
    rpm -ivh chefdk.rpm
else echo "We could not detect your OS type, cannot install chefdk!"
fi
