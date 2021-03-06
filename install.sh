#/!/bin/bash

#install software
yum install nano perl wget -y

# install apache
yum install httpd -y

# get some repos
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# get latest mysql
wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
yum localinstall mysql-community-release-el7-5.noarch.rpm -y
yum update -y
yum install mysql-community-server -y
systemctl enable mysqld.service
/bin/systemctl start  mysqld.service

# install some dev tools
yum groupinstall 'Development tools' -y

yum install --enablerepo=webtatic-testing php70w php70w-opcache php70w-cli php70w-common php70w-gd php70w-mbstring php70w-mcrypt php70w-pdo php70w-xml php70w-mysqlnd -y

#todo 
rm /etc/httpd/conf.d/php.conf -rf
rm /etc/httpd/conf.modules.d/10-php.conf -rf

# load php into apache
touch /etc/httpd/conf.d/php7.conf
cat << EOF > /etc/httpd/conf.d/php7.conf
LoadModule php7_module        /usr/lib64/httpd/modules/libphp7.so
<FilesMatch \.php$> 
SetHandler application/x-httpd-php
</FilesMatch> 
EOF

#make sure you can index with php and use clean urls in drupal
touch /etc/httpd/conf.d/html.conf
cat << EOF > /etc/httpd/conf.d/html.conf
<Directory "/var/www/html">    
  Options Indexes FollowSymLinks
  AllowOverride All
  Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.php index.html
</IfModule>
EOF

systemctl enable httpd
systemctl start httpd

#disable selinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

#setup mysql config
systemctl stop mysql
rm -rf ib_logfile0 ib_logfile1
mv /etc/my.cnf /etc/my.cnf.old
mv ./my.cnf /etc/my.cnf
systemctl start mysql

#stop and disable firewall (only for testing)
systemctl disable firewalld
systemctl stop firewalld

#Change ssh port to 9191 to prevent bruteforincg (needs editing)
#sed -i 's/"#PORT 22"/"PORT 9191"/g' /etc/ssh/sshd_config /etc/ssh/sshd_config




