#-------------------------------------------------
#    regular commands
#-------------------------------------------------
hadoop fs -ls -R /
hadoop fs -rmr /user/hive/warehouse/xt_cfbdm_safe.db/employees07/
hdfs dfsadmin -report
#-------------------------------------------------
#    copy file
#-------------------------------------------------
hadoop fs -copyToLocal /user/hive/warehouse/xt_cfbdm_safe.db/employees07/country=CHINA/state=HK/input.q /app/document/output.q
hadoop fs -copyFromLocal /app/document/input.q /user/xcc/input/input.q
hadoop fs -cp filepath1 filepath2
#-------------------------------------------------
#     deal with filewalld
#-------------------------------------------------
telnet 11.258.154 50070
netstat -an | grep 50070
firewall-cmd --add-port=50070/tcp
#-------------------------------------------------
#     post step on hadoop vmware from junjian
#-------------------------------------------------
change VMware network to "host-only" model
then change eth0 to 192.168.10.2
then change hosts to 192.168.10.2 cfbdm
then restart network service and hadoop software
#-------------------------------------------------
#     cluster setup
#-------------------------------------------------
# Step 1
安装虚拟机master，
编辑虚拟机设置 / 1G 内存 / host-only模式
将虚拟机ip设置与vmnet1同网段，自启动，静态
vi /etc/sysconfig/network-scripts/ifcfg-eno16777736
	#BOOTPROTO=dhcp
	#ONBOOT=no
	ONBOOT=yes
	BOOTPROTO=static
	IPADDR=192.168.10.3
service network restart
SecureCRT 链接虚拟机操作
# Step 2
groupadd hadoop
useradd hadoop -g hadoop
# Step 3
切入FTP
cd /opt
lcd E:\00_FileTree\00_Backup_Software20161001
put jdk-7u25-linux-x64.tar.gz
tar -zxvf jdk-7u25-linux-x64.tar.gz
mv jdk1.7.0_25/ java
vi /etc/profile
	export JAVA_HOME=/opt/java
	export PATH=$JAVA_HOME/bin:$PATH
source /etc/profile
chown -R hadoop:hadoop java/
# Step 4
put hadoop-2.6.4.tar.gz
tar -zxvf hadoop-2.6.4.tar.gz
mv hadoop-2.6.4 hadoop
vi /etc/profile
	export HADOOP_HOME=/opt/hadoop
	export PATH=$HADOOP_HOME/bin:$PATH
source /etc/profile
chown -R hadoop:hadoop hadoop/
# Step 5
vi /etc/hosts
	192.168.10.3 master
	192.168.10.4 slave1
	192.168.10.5 slave2
# Step 6
su hadoop
vi hadoop/etc/hadoop/hadoop-env.sh
export JAVA_HOME=/opt/java
vi hadoop/etc/hadoop/core-site.xml
	<property>
	  <name>hadoop.tmp.dir</name>
	  <value>/hadoop</value>
	</property>
	<property>
	  <name>fs.default.name</name>
	  <value>hdfs://master:9000</value>
	</property>
	<property>
	  <name>dfs.name.dir</name>
	  <value>/hadoop/name</value>
	</property>
vi hadoop/etc/hadoop/hdfs-site.xml
	<property>
	    <name>dfs.replication</name>
	    <value>3</value>
	</property>
	<property>
	    <name>dfs.data.dir</name>
	    <value>/hadoop/data</value>
	</property>
cp hadoop/etc/hadoop/mapred-site.xml.template hadoop/etc/hadoop/mapred-site.xml
vi hadoop/etc/hadoop/mapred-site.xml
	<property>
	    <name>mapred.job.tracker</name>
	    <value>master:9001</value>
	</property>
	<property>
	    <name>mapred.system.dir</name>
	    <value>/hadoop/mapred_system</value>
	</property>
	<property>
	    <name>mapred.local.dir</name>
	    <value>/hadoop/mapred_local</value>
	</property>
vi hadoop/etc/hadoop/masters
	master
vi hadoop/etc/hadoop/slaves
	#localhost
	master
	slave1
	slave2
# Step 7
创建master虚拟机克隆slave1, slave2, 并修改主机名和IP地址
replace MAC address with the "new" MAC address found at "网络适配器 / 高级"
vi /etc/sysconfig/network-scripts/ifcfg-eno16777736
	#HWADDR=00:0C:29:04:D5:B0
	HWADDR=00:0C:29:A4:98:C7
	IPADDR=192.168.10.4
passwd hadoop
# Step 8
su hadoop
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cp id_rsa.pub authorized_keys
chmod 600 ~/.ssh/authorized_keys
scp authorized_keys slave1:/home/hadoop/.ssh/ #slave1 端的文件夹及文件的权限也要设置
# Step 9
root# mkdir /hadoop #slave1 端也要建文件夹，授予权限
root# chown -R hadoop:hadoop /hadoop
hadoop$ hadoop namenode -format
./start-all.sh
# Step 10
jps

