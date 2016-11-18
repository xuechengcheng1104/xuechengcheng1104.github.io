#-------------------------------------------------
#    mount filesystem type 'ntfs'
#-------------------------------------------------
rpm -ivh ntfs-3g-2015.3.14-2.el7.x86_64.rpm 
Sat Sep 24 09:40:38 CST 2016
#-------------------------------------------------
#   mount the image file of rhela
#-------------------------------------------------
mount /dev/sdc5 /app/usb01
mount /app/usb01/FileTree/11_EnvorimentSetup/11_MySQLInstall/rhel-server-7.0-x86_64-dvd.iso /app/package/rhel_iso/
Sat Sep 24 10:00:14 CST 2016
#-------------------------------------------------
#   registe reposible to local iso file
#-------------------------------------------------
cd /etc/yum.repos.d/
vi local.repo
	[base]
	name=local
	baseurl=file:///app/package/rhel_iso
	gpgcheck=0
	enabled=1
yum makecache
yum install vim
Sat Sep 24 10:06:52 CST 2016
#-------------------------------------------------
#  install MySQL
#-------------------------------------------------
yum install libaio
yum install net-tools
yum remove mariadb-libs
rpm -ivh MySQL-*.rpm
	MySQL-client-5.6.29-1.el6.x86_64.rpm
	MySQL-devel-5.6.29-1.el6.x86_64.rpm
	MySQL-embedded-5.6.29-1.el6.x86_64.rpm
	MySQL-server-5.6.29-1.el6.x86_64.rpm
	MySQL-shared-5.6.29-1.el6.x86_64.rpm
	MySQL-test-5.6.29-1.el6.x86_64.rpm
yum install perl-Module-Build
mysql_install_db  --datadir=/app/mysqldatadir --user=mysql
mysqld_safe --datadir=/app/mysqldatadir/ --user=mysql
mysqladmin -u root password '123456'
Sat Sep 24 18:23:22 CST 2016
#-------------------------------------------------
#  install Hadoop
#-------------------------------------------------
yum install java-1.7.0-openjdk
yum info java-1.7.0-openjdk
rpm -ql java-1.7.0-openjdk
tar -zxvf hadoop-2.6.4.tar.gz
cp -R hadoop-2.6.4 /app
echo 'export HADOOP_HOME=/app/hadoop-2.6.4' >> /etc/profile
echo 'export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH' >> /etc/profile
find / -name java
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64/jre' >> /etc/profile
echo 'export HADOOP\_PREFIX=/app/hadoop-2.6.4' >> /etc/profile
. /etc/profile
vim etc/hadoop/hadoop-env.sh
	# The java implementation to use.
	export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64/jre
vim etc/hadoop/hdfs-site.xml
     <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
vim etc/hadoop/mapred-site.xml
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
vim etc/hadoop/yarn-site.xml
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
vim etc/hadoop/core-site.xml
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
hdfs namenode -format
start-dfs.sh
hdfs dfs -ls /
netstat -an | grep 50070
yum install redhat-indexhtml
rpm -ivh lynx-2.8.8-0.3.dev15.el7.x86_64.rpm
Sat Sep 24 20:54:25 CST 2016
#-------------------------------------------------
#  install hive
#-------------------------------------------------
yum install yum-utils
yumdownloader mysql-connector-java
rpm -ql mysql-connector-java
cp /usr/share/java/mysql-connector-java.jar /app/apache-hive-2.1.0-bin/lib/
vim conf/hive-site.xml
    <property>
        <name>hive.metastore.local</name>
        <value>true</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://127.0.0.1:3306/hive?characterEncoding=UTF-8</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.jdbc.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>hive</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>hive123</value>
    </property>
mysql -u root -p123456
    CREATE USER 'hive'@'localhost' IDENTIFIED BY 'hive123';
    GRANT ALL PRIVILEGES ON *.* TO 'hive'@'localhost' WITH GRANT OPTION;
    flush privileges;
mysql -u hive -phive123
    CREATE DATABASE hive;
/app/apache-hive-2.1.0-bin/bin/hive 2> error
bin/schematool -dbType mysql -initSchema
df -B g
free -m
Sun Sep 25 09:55:33 CST 2016
