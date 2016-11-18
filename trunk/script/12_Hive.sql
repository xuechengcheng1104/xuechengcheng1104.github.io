
--#-------------------------------------------------
--#    查看表信息
--#-------------------------------------------------
SHOW PARTITIONS employees03;
SHOW CREATE TABLE l_cust_basic_info;
describe formatted xt_cfbdm_safe.l_cust_basic_info; --创建时间，修改时间
describe formatted xt_cfbdm_safe.l_cust_basic_info partition (elt_dt=date'2016-11-16'); --表中记录条数及表物理存储大小
--#-------------------------------------------------
--#    解析json字段
--#-------------------------------------------------
select get_json_object(tablename.columnname, '$.jsoncolumnname') from tablename;
--#-------------------------------------------------
--#    删除字段
--#-------------------------------------------------
alter table product_analysis_weekly replace columns
(
	month_no string comment '...',
	week_no string comment '...'
);
--#-------------------------------------------------
--#    增加字段
--#-------------------------------------------------
--先use目标库，表名不可前缀库名
use xt_trapp_safe;
alter table product_analysis_weekly add columns
(
	online_standard_amt string comment '...',
	offline_standard_amt string comment '...',
	total_standard_amt string comment '...'
);
--#-------------------------------------------------
--#    hive 命令行接口不能输入制表符，先转制表符为空格。
--#-------------------------------------------------
--#-------------------------------------------------
--#    报错：  <EOF>
--#-------------------------------------------------
注释语句里不能出现分好";"
--#-------------------------------------------------
--#    报错：  arrayindexoutofboundsexception
--#-------------------------------------------------
使用临时表存放中间数据，避免单个语句逻辑过于复杂。
--#-------------------------------------------------
--#    时间（带小数点）以字符串存储，转换为 timestamp
--#-------------------------------------------------
cast(LCD, as timestamp)
--#-------------------------------------------------
--#    hive实现增量更新
--#-------------------------------------------------
create table customer_temp like customer;
insert overwrite table customer
select * from customer_temp
union all
select a.* 
from customer a
left outer join customer_temp b
	on a.id = b.id 
where b.id is null
--#-------------------------------------------------
--#    hive 变量
--#-------------------------------------------------
set hivevar:txdate=2016-10-24
--#-------------------------------------------------
--#    hive 数据类型
--#-------------------------------------------------
int
float
decimal(22, 2)
string
date
timestamp
--#-------------------------------------------------
--#    hive to_date()
--#-------------------------------------------------
to_date(lcd)='2016-10-20'
--#-------------------------------------------------
--#    计算拥有同一手机号的记录数量（cust_num 不为空）
--#-------------------------------------------------
count(cust_num) over (partition by mobile_num) as rn
--#-------------------------------------------------
--#    解决hive交互模式退格键乱码
--#-------------------------------------------------
vim /etc/profile
    stty erase ^H
--#-------------------------------------------------
--#    Data export & import
--#-------------------------------------------------
/app/apache-hive-2.1.0-bin/bin/hive -e "describe extended xt_cfbdm_safe.employees" >> /app/document/hiveoutput.sh
/app/apache-hive-2.1.0-bin/bin/hive -f hiveinput.sh >> /app/document/hiveoutput.sh
insert overwrite local directory '/home/wyp/wyp' select * from wyp;
insert overwrite directory '/home/wyp/hdfs' select * from wyp;
load data local inpath '/app/document/hiveoutput.sh' OVERWRITE INTO TABLE employees07 PARTITION (country, state);
load data inpath '/app/document/hiveoutput.sh' into table employees;
--#-------------------------------------------------
--#    查看数据仓库信息
--#-------------------------------------------------
SHOW TABLES IN xt_cfbdm_safe;
SHOW TABLES 'empl.*';
describe database xt_cfbdm_safe;
describe database extended test03;
--#-------------------------------------------------
--#    表数据汇总成一串文本
--#-------------------------------------------------
Step 01 ： 将字段值转化为字符串
    nvl(cast(column_value as string), '')
Step 02 :  将每个记录连接成一个字符串
    concat_ws(',', column_name01, column_name02, column_name03, ... )
Step 03 :  将仅剩的一列字符串转变成一个列表结构
    collect_set(concat(column_sum_name))
Step 04:  将列表连接成一个字符串
    conncat_ws('&', collect_set(concat(column_sum_name)))
--#-------------------------------------------------
--#    DATABASE
--#-------------------------------------------------
CREATE DATABASE IF NOT EXISTS test03 
COMMENT 'Holds all financial tables'
LOCATION '/user/xcc/warehouse/test01.db'
WITH DBPROPERTIES ('creator' = 'Mark Moneybags', 'date' = '2012-01-02');
ALTER DATABASE test03 SET DBPROPERTIES ('edited-by' = 'Joe Dba');
DROP DATABASE IF EXISTS xt_cfbdm_safe CASCADE;
--#-------------------------------------------------
--#    TABLE
--#-------------------------------------------------
hv> CREATE EXTERNAL TABLE IF NOT EXISTS weblog 
	(
		user_id INT, 
		url STRING COMMENT 'the path to archive resource', 
		source_ip STRING
	)
	COMMENT 'the log file of web'
	PARTITIONED BY (dt STRING)
	CLUSTERED BY (user_id) SORTED BY (user_id ASC) INTO 96 BUCKETS
	ROW FORMAT DELIMITED 
		FIELDS TERMINATED BY '\t'
		LINES TERMINATED BY '\n'
	STORED AS TEXTFILE
	LOCATION '/user/hive/warehouse/xt_cfbdm_safe.db/employees';
hv> CREATE TABLE IF NOT EXISTS xt_cfbdm_safe.employees02 LIKE xt_cfbdm_safe.employees;
hv> ALTER TABLE xt_cfbdm_safe.employee_partition ADD IF NOT EXISTS
	    PARTITION (country='CHINA', state='HK') LOCATION '/logs/2011/01/01'
	    PARTITION (country='CHINA', state='ShangHai') LOCATION '/logs/2011/01/02'
	    PARTITION (country='CHINA', state='BeiJing') LOCATION '/logs/2011/01/03';
hv> ALTER TABLE employees06 RENAME TO employees07;
hv> ALTER TABLE employees07 CHANGE COLUMN name 
		firstname int COMMENT 'the first part of name';
hv> ALTER TABLE employees07 ADD COLUMNS 
	(
	    name STRING COMMENT 'Application name'
	);
hv> ALTER TABLE employees07 REPLACE COLUMNS (
	    name STRING COMMENT 'Employee name',
	    salary FLOAT COMMENT 'Employee salary'
	);
hv> insert into employees04 partition (country='CHINA', state='HK') 
	select 'lisi', '13.3';
	--'use dbname' first, before excute this statment
hv> insert overwrite table employees 
	select name, salary 
	from employees07 
	where country='CHINA' and state='HK';
hv> FROM employees07
    INSERT OVERWRITE TABLE employees08 PARTITION (dt='2009-02-25')
    SELECT '1' ,name ,'2'
    WHERE country='CHINA' and state='HK';
hv> truncate table employees04;
hv> DROP TABLE IF EXISTS employees;
	--the expressions occuring in group by clause must be in the select clause too 
hv> group by expressions	
--#-------------------------------------------------
--#    Special question
--#-------------------------------------------------
trim()	--去除字段值中的空格
order by --如果 expression 已经出现在 select 子句中并且赋了别名，就取别名排序
--#-------------------------------------------------
--#    User
--#-------------------------------------------------
SHOW GRANT USER hduser0301 ON DATABASE xt_cfbdm_safe;
--#-------------------------------------------------
--#    HIVE常用函数集合
--#-------------------------------------------------
hive> select 1 from lxw_dual where 1=1;
hive> select 1 from lxw_dual where 1 <> 2;
hive> select 1 from lxw_dual where 1 < 2;
hive> select 1 from lxw_dual where 1 <= 1;
hive> select 1 from lxw_dual where 2 > 1;
hive> select 1 from lxw_dual where 1 >= 1;
hive> select * from lxw_dual;
hive> select a,b,a<b,a>b,a=b from lxw_dual;
hive> select 1 from lxw_dual where null is null;
hive> select 1 from lxw_dual where 1 is not null;
hive> select 1 from lxw_dual where 'football' like 'foot%';
hive> select 1 from lxw_dual where 'football' like 'foot____';
hive> select 1 from lxw_dual where NOT 'football' like 'fff%';
hive> select 1 from lxw_dual where 'footbar' rlike '^f.*r$';
hive> select 1 from lxw_dual where '123456' rlike '^\\d+$';
hive> select 1 from lxw_dual where '123456aa' rlike '^\\d+$';
hive> select 1 from lxw_dual where 'footbar' REGEXP '^f.*r$';
hive> select 1 + 9 from lxw_dual;
hive> create table lxw_dual as select 1 + 1.2 from lxw_dual;
hive> describe lxw_dual;
hive> select 10 – 5 from lxw_dual;
hive> create table lxw_dual as select 5.6 – 4 from lxw_dual;
hive> describe lxw_dual;
hive> select 40 * 5 from lxw_dual;
hive> select 40 / 5 from lxw_dual;
hive> select ceil(28.0/6.999999999999999999999) from lxw_dual limit 1;   
hive> select ceil(28.0/6.99999999999999) from lxw_dual limit 1;          
hive> select 41 % 5 from lxw_dual;
hive> select 8.4 % 4 from lxw_dual;
hive> select round(8.4 % 4 , 2) from lxw_dual;
hive> select 4 & 8 from lxw_dual;
hive> select 6 & 4 from lxw_dual;
hive> select 4 | 8 from lxw_dual;
hive> select 6 | 8 from lxw_dual;
hive> select 4 ^ 8 from lxw_dual;
hive> select 6 ^ 4 from lxw_dual;
hive> select ~6 from lxw_dual;
hive> select ~4 from lxw_dual;
hive> select 1 from lxw_dual where 1=1 and 2=2;
hive> select 1 from lxw_dual where 1=2 or 2=2;
hive> select 1 from lxw_dual where not 1=2;
hive> select round(3.1415926) from lxw_dual;
hive> select round(3.5) from lxw_dual;
hive> create table lxw_dual as select round(9542.158) from lxw_dual;
hive> describe lxw_dual;
hive> select round(3.1415926,4) from lxw_dual;
hive> select floor(3.1415926) from lxw_dual;
hive> select floor(25) from lxw_dual;
hive> select ceil(3.1415926) from lxw_dual;
hive> select ceil(46) from lxw_dual;
hive> select ceiling(3.1415926) from lxw_dual;
hive> select ceiling(46) from lxw_dual;
hive> select rand() from lxw_dual;
hive> select rand() from lxw_dual;
hive> select rand(100) from lxw_dual;
hive> select rand(100) from lxw_dual;
hive> select exp(2) from lxw_dual;
hive> select ln(7.38905609893065) from lxw_dual;
hive> select log10(100) from lxw_dual;
hive> select log2(8) from lxw_dual;
hive> select log(4,256) from lxw_dual;
hive> select pow(2,4) from lxw_dual;
hive> select power(2,4) from lxw_dual;
hive> select sqrt(16) from lxw_dual;
hive> select bin(7) from lxw_dual;
hive> select hex(17) from lxw_dual;
hive> select hex('abc') from lxw_dual;
hive> select unhex('616263') from lxw_dual;
hive> select unhex('11') from lxw_dual;
hive> select unhex(616263) from lxw_dual;
hive> select conv(17,10,16) from lxw_dual;
hive> select conv(17,10,2) from lxw_dual;
hive> select abs(-3.9) from lxw_dual;
hive> select abs(10.9) from lxw_dual;
hive> select pmod(9,4) from lxw_dual;
hive> select pmod(-9,4) from lxw_dual;
hive> select sin(0.8) from lxw_dual;
hive> select asin(0.7173560908995228) from lxw_dual;
hive> select cos(0.9) from lxw_dual;
hive> select acos(0.6216099682706644) from lxw_dual;
hive> select positive(-10) from lxw_dual;
hive> select positive(12) from lxw_dual;
hive> select negative(-5) from lxw_dual;
hive> select negative(8) from lxw_dual;
hive> select from_unixtime(1323308943,'yyyyMMdd') from lxw_dual;
hive> select unix_timestamp() from lxw_dual;
hive> select unix_timestamp('2011-12-07 13:01:03') from lxw_dual;
hive> select unix_timestamp('20111207 13:01:03','yyyyMMddHH:mm:ss') from lxw_dual;
hive> select to_date('2011-12-08 10:03:01') from lxw_dual;
hive> select year('2011-12-08 10:03:01') from lxw_dual;
hive> select year('2012-12-08') from lxw_dual;
hive> select month('2011-12-08 10:03:01') from lxw_dual;
hive> select month('2011-08-08') from lxw_dual;
hive> select day('2011-12-08 10:03:01') from lxw_dual;
hive> select day('2011-12-24') from lxw_dual;
hive> select hour('2011-12-08 10:03:01') from lxw_dual;
hive> select minute('2011-12-08 10:03:01') from lxw_dual;
hive> select second('2011-12-08 10:03:01') from lxw_dual;
hive> select weekofyear('2011-12-08 10:03:01') from lxw_dual;
hive> select datediff('2012-12-08','2012-05-09') from lxw_dual;
hive> select date_add('2012-12-08',10) from lxw_dual;
hive> select date_sub('2012-12-08',10) from lxw_dual;
hive> select if(1=2,100,200) from lxw_dual;
hive> select if(1=1,100,200) from lxw_dual;
hive> select COALESCE(null,'100','50') from lxw_dual;
hive> Select case 100 when 50 then 'tom' when 100 then 'mary'else 'tim' end from lxw_dual;
hive> Select case 200 when 50 then 'tom' when 100 then 'mary'else 'tim' end from lxw_dual;
hive> select case when 1=2 then 'tom' when 2=2 then 'mary' else'tim' end from lxw_dual;
hive> select case when 1=1 then 'tom' when 2=2 then 'mary' else'tim' end from lxw_dual;
hive> select length('abcedfg') from lxw_dual;
hive> select reverse('abcedfg') from lxw_dual;
hive> select concat('abc','def','gh') from lxw_dual;
hive> select concat_ws(',','abc','def','gh') from lxw_dual;
hive> select substr('abcde',3) from lxw_dual;
hive> select substring('abcde',3) from lxw_dual;
hive> select substr('abcde',-1) from lxw_dual; （和Oracle相同）
hive> select substr('abcde',3,2) from lxw_dual;
hive> select substring('abcde',3,2) from lxw_dual;
hive> select substring('abcde',-2,2) from lxw_dual;
hive> select upper('abSEd') from lxw_dual;
hive> select ucase('abSEd') from lxw_dual;
hive> select lower('abSEd') from lxw_dual;
hive> select lcase('abSEd') from lxw_dual;
hive> select trim(' abc ') from lxw_dual;
hive> select ltrim(' abc ') from lxw_dual;
hive> select rtrim(' abc ') from lxw_dual;
hive> select regexp_replace('foobar', 'oo|ar', '') from lxw_dual;
hive> select regexp_extract('foothebar', 'foo(.*?)(bar)', 1) fromlxw_dual;
hive> select regexp_extract('foothebar', 'foo(.*?)(bar)', 2) fromlxw_dual;
hive> select regexp_extract('foothebar', 'foo(.*?)(bar)', 0) fromlxw_dual;
hive> select parse_url('http://facebook.com/path1/p.PHP?k1=v1&k2=v2#Ref1', 'HOST') from lxw_dual;
hive> select parse_url('http://facebook.com/path1/p.php?k1=v1&k2=v2#Ref1', 'QUERY','k1') from lxw_dual;
hive> select space(10) from lxw_dual;
hive> select length(space(10)) from lxw_dual;
hive> select repeat('abc',5) from lxw_dual;
hive> select ascii('abcde') from lxw_dual;
hive> select lpad('abc',10,'td') from lxw_dual;
hive> select rpad('abc',10,'td') from lxw_dual;
hive> select split('abtcdtef','t') from lxw_dual;
hive> select find_in_set('ab','ef,ab,de') from lxw_dual;
hive> select find_in_set('at','ef,ab,de') from lxw_dual;
hive> select count(*) from lxw_dual;
hive> select count(distinct t) from lxw_dual;
hive> select sum(t) from lxw_dual;
hive> select sum(distinct t) from lxw_dual;
hive> select avg(t) from lxw_dual;
hive> select avg (distinct t) from lxw_dual;
hive> select min(t) from lxw_dual;
hive> select max(t) from lxw_dual;
hive> select histogram_numeric(100,5) from lxw_dual;
hive> Create table lxw_test as select map('100','tom','200','mary')as t from lxw_dual;
hive> describe lxw_test;
hive> select t from lxw_test;
hive> create table lxw_test as select struct('tom','mary','tim')as t from lxw_dual;
hive> describe lxw_test;
hive> select t from lxw_test;
hive> create table lxw_test as select array("tom","mary","tim") as t from lxw_dual;
hive> describe lxw_test;
hive> select t from lxw_test;
hive> create table lxw_test as select array("tom","mary","tim") as t from lxw_dual;
hive> select t[0],t[1],t[2] from lxw_test;
hive> Create table lxw_test as select map('100','tom','200','mary') as t from lxw_dual;
hive> select t['200'],t['100'] from lxw_test;
hive> create table lxw_test as select struct('tom','mary','tim')as t from lxw_dual;
hive> describe lxw_test;
hive> select t.col1,t.col3 from lxw_test;
hive> select size(map('100','tom','101','mary')) from lxw_dual;
hive> select size(array('100','101','102','103')) from lxw_dual;
hive> select cast(1 as bigint) from lxw_dual;








