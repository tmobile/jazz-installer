curl -o chefdk.rpm https://packages.chef.io/files/stable/chefdk/1.4.3/el/7/chefdk-1.4.3-1.el7.x86_64.rpm
rpm -Kvv --nosignature chefdk.rpm
rpm -ivh chefdk.rpm


