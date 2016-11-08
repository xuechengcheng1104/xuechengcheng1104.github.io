##################################################
#    mysql 更新数据保护disable
##################################################
MySQL Workbench / Edit / Preference / SQL Queries / unselect "Safe Updates", Forbid ...
and reconnect
##################################################
#    删除字段
##################################################
alter table id_name 
	drop column age,
	drop column address; 
##################################################
#    字符串转时间
##################################################
str_to_date('2009-12-20 12:00:00', '%Y-%m-%d %H:%i:%s') from dual;
date_format(date, format)
unix_timestamp()
str_to_date(str, format)
from_unixtime(unix_timestamp, format)
cast(etl_dt as char(16))='2016-10-21'
##################################################
#    修改字段类型
##################################################
alter table cfbbi.workday_table_tmp
	modify datevalue datetime,
	modify fcd datetime,
	modify lcd datetime;
##################################################
#    建分区表
##################################################
CREATE TABLE employees (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '9999-12-31',
    job_code INT NOT NULL,
    store_id INT NOT NULL
)
/*
PARTITION BY RANGE (store_id) (
    PARTITION p0 VALUES LESS THAN (6),
    PARTITION p1 VALUES LESS THAN (11),
    PARTITION p2 VALUES LESS THAN (16),
    PARTITION p3 VALUES LESS THAN MAXVALUE
);
*/
/*
PARTITION BY LIST(store_id)
    PARTITION pNorth VALUES IN (3,5,6,9,17),
    PARTITION pEast VALUES IN (1,2,10,11,19,20),
    PARTITION pWest VALUES IN (4,12,13,14,18),
    PARTITION pCentral VALUES IN (7,8,15,16)
);
*/
PARTITION BY HASH(store_id)
PARTITIONS 4;
##################################################
#    删分区，插入分区数据, 建分区
##################################################
alter table ctbbi.d_mc_estim_fix_prod_matr_recmd drop partition p20160815;
insert into ctbbi.d_mc_estim_fix_prod_matr_recmd
(...)
values
(...),
(...),
(...);
alter table ctbbi.d_mc_estim_fix_prod_matr_recmd add partition (partition p20160424 values in (to_days('2016-04-24')));
##################################################
#    查看某表的所有分区
##################################################
select concat('\'', partition_name, '\'')
from information_schema.partitions
where table_name='d_mc_estim_fix_prod_matr_recmd'
and partition_name like '%08%';
##################################################
#    初始化MySQL&启动MySQL
##################################################
yum install perl-module
mysql_install_db --user=mysql
mysqld_safe --user=mysql &
##################################################
#    mysql常用命令
##################################################
mysqladmin version
mysqladmin variables
mysqladmin shutdown
mysqlshow
mysqlshow mysql
msyql -e "select xxx" mysql
mysql -h localhost -u root -p
SHOW variables like '%dir%';
SHOW GLOBAL STATUS;
##################################################
#     set password for mysql user
##################################################
SET PASSWORD FOR user = PASSWORD('new_password');
##################################################
#     postinstallation of httpd
##################################################
systemctl enable httpd.service
systemctl start httpd.service
systemctl status httpd.service
add 'ServerName:80' into httpd.conf
check configure information include the error log: httpd -S
put file 'index.html' into /var/www/html direcotory
##################################################
#    MySQL导数据
##################################################
LOAD DATA LOCAL INFILE 'loadfile.q' INTO TABLE loadfile;
##################################################
#    export data into file
##################################################
select * from information_schema.tables into outfile "output.q";
##################################################
#    脚本编码字体：
##################################################
consolas
##################################################
#    Using MySQL in Batch Modle
##################################################
mysql -u root -p < selectloadfile.q
##################################################
#    show table creation information
##################################################
SHOW CREATE TABLE tablename;
DESCRIBE tablename;





















