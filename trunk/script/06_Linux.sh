﻿
#-------------------------------------------------
#    文件编码问题
#-------------------------------------------------
dos2unix filename
vim / :set fileencoding #查看文件编码
echo $LANG #查看系统编码
secureCRT / options / session / Appearance / Character / UTF-8 #设置终端字符集
#-------------------------------------------------
#    SecureCRT 设置语法高亮，多色显示
#-------------------------------------------------
Options  -> Session Options -> Emulation (Terminal) 
其中Terminal选择 [Xterm]，勾选[ANSI Color]和[Select an alternate keyboard emulation]
#-------------------------------------------------
#    Prentice.Hall-Unix.Shells.By.Example,4th.Edition.chm 文件解锁
#-------------------------------------------------
right click / property / unlock
#-------------------------------------------------
#    关机 / 重启
#-------------------------------------------------
shutdown -r now
shutdown -h now
poweroff
#-------------------------------------------------
#    kill linux account
#-------------------------------------------------
pkill -kill -t pts/0
#-------------------------------------------------
#    查找进程
#-------------------------------------------------
ps -ef | grep mysql
#-------------------------------------------------
#    Yum
#-------------------------------------------------
列出所有已安装的软件包
命令：yum list installed
使用YUM获取软件包信息
命令：yum info <package_name>
使用YUM查找软件包
命令：yum search <keyword>
#-------------------------------------------------
#    下载一个RPM包：
#-------------------------------------------------
$ sudo yum install yum-utils
$ sudo yumdownloader <package-name>
#-------------------------------------------------
#    查看rpm包安装路径
#-------------------------------------------------
rpm -ql xxx
example: /usr/share/doc/python-docs-2.7.5
#-------------------------------------------------
#    查看内存使用情况
#-------------------------------------------------
free
#-------------------------------------------------
#    解压缩
#-------------------------------------------------
tar -zxvf jdk-7u25-linux-x64.tar.gz
tar -xvf xxx.tar
#-------------------------------------------------
#    压缩
#-------------------------------------------------
tar -zcvf xxx.tar.gz /xxx
tar -cvf xxx.tar /xxx
#-------------------------------------------------
#     deal with iptables
#-------------------------------------------------
telnet 11.258.154 50070
netstat -an | grep 50070
firewall-cmd --add-port=50070/tcp
#-------------------------------------------------
#     子网掩码，IP地址范围
#-------------------------------------------------
inet 11.240.158.254
netmask 255.255.224.0
158(1001 1110)
224(1110 0000)
min:128(1000 0000)
max:160(1001 1111)
result:11.240.128-160.0-256
#-------------------------------------------------
#     find one file by name
#-------------------------------------------------
find / -name output.q
#-------------------------------------------------
#     find one file which obtain the expression
#-------------------------------------------------
grep -l "xxx" ./*
#-------------------------------------------------
#     how to set the network of vmware
#-------------------------------------------------
1、Bridged方式
虚拟系统的IP可以设置成与本机系统在同一个网段，虚拟机相当于网络内部一个独立的机器，与本机共同插在一个Hub上，网络内的其他机器可以访问虚拟机，虚拟机也可以访问网络内其他机器，当然与本机的互访也不成问题。
主机拔掉网线后，虚拟机无法与主机通过网络的方式进行通讯。
2、NAT方式（需要用vmnet8）
使用VMware提供的NAT和DHCP服务，虚拟机使用主机中过的虚拟网卡Vmnet8作为网关，这种方式可以实现主机和虚拟机通信，虚拟机也能够访问互联网，但是互联网不能访问虚拟机。
只需要设置虚拟机的网络为DHCP，就可以ping通Vmnet8了。
也可以手动设置IP，ip设置与vmnet8同网段,gateway，netmask，broadcast设置与vmnet8相同,dns设置与主机相同。
如果使用NAT方式：确保Eidt-Virtual Network Editor中的DHCP处于Start状态
3、host-only方式（需要用vmnet1）
只能进行虚拟机和主机之间的网络通信，虚拟机不能访问外部网络。
将虚拟机ip设置与vmnet1同网段,gateway设置成vmnet1的ip,其余设置与vmnet1相同,dns设置与主机相同
对于所有的联网方式：注意关闭防火墙
#-------------------------------------------------
#     合并多个文本文件
#-------------------------------------------------
linux:  cat * > ouput.q
windows:    copy * output.q
#-------------------------------------------------
#    IP地址配置文件
#-------------------------------------------------
/etc/sysconfig/network-scripts/ifcfg-eth0
#-------------------------------------------------
#    修改IP地址后重启网络服务
#-------------------------------------------------
service network restart
#-------------------------------------------------
#    Vmware和主机联网
#-------------------------------------------------
Vmware网络改为“桥接模式”，
修改IP地址和主机在一个网段，
配置网关和子网掩码和主机一样
先注释掉相关默认配置
如果单个ping通，把网断开重连

ONBOOT=yes    #this paramenter must be in front of IPADDR
BOOTPROTO=static
IPADDR=192.168.42.17
NETMASK=255.255.255.0
GATEWAY=192.168.42.129
#-------------------------------------------------
#    查看已经装的所有软件包
#-------------------------------------------------
rpm -qa
#-------------------------------------------------
#    生成RSA秘钥对，免密码登录
#-------------------------------------------------
$ ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
$ cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
#-------------------------------------------------
#    查找文件命令
#-------------------------------------------------
find ./ -name '*slave*'
#-------------------------------------------------
#    显示所有子目录
#-------------------------------------------------
ls -lR ./
#-------------------------------------------------
#    是环境变量生效
#-------------------------------------------------
source ~/.bashrc
#-------------------------------------------------
#    rpm安装
#-------------------------------------------------
rpm -ivh xxx.rpm
#-------------------------------------------------
#    配置DNS
#-------------------------------------------------
/etc/resolv.conf在其中添加：
nameserver 8.8.8.8
nameserver 8.8.4.4
search localdomain
然后：
service network restart
#-------------------------------------------------
#    卸载安装包
#-------------------------------------------------
yum remove xxx
#-------------------------------------------------
#    配置CENTOS源
#-------------------------------------------------
http://mirrors.aliyun.com/help/centos
#-------------------------------------------------
#    踢掉用户
#-------------------------------------------------
pkill -kill -t pts/0
#-------------------------------------------------
#    配置本地源
#-------------------------------------------------
mkdir /yum/Server/  
mount /dev/hdc  /yum/  
vi /etc/yum.repos.d/local.repo

[base]  
name=local  
baseurl=file:///yum/Server  
gpgcheck=0  
enabled=1
#-------------------------------------------------
#    yum
#-------------------------------------------------
yum install/list/search/info/deplist/remove