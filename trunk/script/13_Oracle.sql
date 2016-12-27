
--**************************************************
--*    查看某用户对表/系统的权限
--**************************************************
select * from user_sys_privs;
select * from all_tab_privs;
--**************************************************
--*    列出schema与table信息
--**************************************************
select owner
	,count(*)
from all_tables
group by owner
order by owner
;
--**************************************************
--*    日期类型字段和日期参数比较
--**************************************************
select sysdate
	,trunc(sysdate)
	,trunc(sysdate,'dd')
	,date'2016-12-23'
	,case when trunc(sysdate,'dd')=date'2016-12-13' then '1' else '0' end
from dual
;
--**************************************************
--*    取前10条数据
--**************************************************
select * from table where rownum<11
--**************************************************
--*    查看磁盘使用情况
--**************************************************
select sum(bytes)/1024/1024/1024 from dba_segments where owner not in ('SYS', 'SYSTEM');
--**************************************************
--*    oracle 插入日期值（DATE）
--**************************************************
insert into cfbic.circle_product_info
(id, product_group_id, date_updated)
values
('1', 'milk', to_date('2016-10-26 12:00:00', 'yyyy-mm-dd hh24:mi:ss'))	--mysql insert characters string directly
--**************************************************
--*    oracle 表名,字段名，区分大小写
--**************************************************
select * from all_tables where lower(table_name) like '%circle_info%';
SELECT ID FROM CFBIC.CIRCLE_INFO; --sqoop导数要使用大写
--**************************************************
--*    pl/sql developer 首选项
--**************************************************
下载安装包instantclient-basic-nt-11.2.0.2.0.zip ， 解压到任意目录
tool / preferences / connection / 
set ORACLE_HOME=D:\app\Matt\product\11.2.0\dbhome_1 
set OCI Libiary=D:\app\Matt\product\11.2.0\instantclient_11_2\oci.dll
edit D:\app\Matt\product\11.2.0\dbhome_1\network\admin\tnsnames.ora
--**************************************************
--*    Oracle 两个用户同事操作数据，相互看到的数据不一致
--**************************************************
用户做完更新后，要commit完成数据提交。
--**************************************************
--*    Oracle installation
--**************************************************
Question 1, 先决条件检查，环境变量PATH实际长度超过期望值
解决方法：删除以D开头的PATH环境变量，退出安装程序，重新安装。原PATH环境变量如下
%CATALINA_HOME%\bin;%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin;C:\Program Files (x86)\Intel\iCLS Client\;C:\Program Files\Intel\iCLS Client\;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;C:\Program Files\Intel\Intel(R) Management Engine Components\DAL;C:\Program Files\Intel\Intel(R) Management Engine Components\IPT;C:\Program Files (x86)\Intel\Intel(R) Management Engine Components\DAL;C:\Program Files (x86)\Intel\Intel(R) Management Engine Components\IPT;D:\Program Files\Microsoft SQL Server\110\DTS\Binn\;D:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\;D:\Program Files\Microsoft SQL Server\110\Tools\Binn\;D:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\;C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\PrivateAssemblies\;D:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\;d:\Program Files (x86)\IDM Computer Solutions\UltraEdit;D:\Program Files\Calibre2\
Item 2, 数据库管理URL
https://localhost:1158/em
--**************************************************
--*    Dictionary
--**************************************************
DICTIONARY
ALL_USERS
ALL_OBJECTS
ALL_TABLES
ALL_VIEWS
ALL_PROCEDURES
ALL_TAB_COLUMNS
--**************************************************
--*    USER
--**************************************************
CREATE USER user161009 IDENTIFIED BY user123456;
GRANT CREATE SESSION TO user161009;
GRANT ALTER ON plants TO scott;
REVOKE ALTER ON plants FROM scott;
ALTER USER HR ACCOUNT UNLOCK;	--unlock one account
ALTER USER HR IDENTIFIED BY HR123456;	--change the password of one account
--**************************************************
--*    TABLE
--**************************************************
CREATE TABLE test_table ( col1 INTEGER, col2 INTEGER );
CREATE TABLE products ( prod_id INT, count INT INVISIBLE );
CREATE TABLE employees
(
  employee_id    NUMBER(6) ,
  first_name     VARCHAR2(20) ,
  last_name      VARCHAR2(25) CONSTRAINT emp_last_name_nn NOT NULL ,
  email          VARCHAR2(25) CONSTRAINT emp_email_nn NOT NULL ,
  phone_number   VARCHAR2(20) ,
  hire_date      DATE CONSTRAINT emp_hire_date_nn NOT NULL ,
  job_id         VARCHAR2(10) CONSTRAINT emp_job_nn NOT NULL ,
  salary         NUMBER(8,2) ,
  commission_pct NUMBER(2,2) ,
  manager_id     NUMBER(6) ,
  department_id  NUMBER(4) ,
  CONSTRAINT emp_salary_min CHECK (salary > 0) ,
  CONSTRAINT emp_email_uk UNIQUE (email)
);
CREATE TABLE list_sales
( 
	 prod_id        NUMBER(6)
	,cust_id        NUMBER
	,time_id        DATE
	,channel_id     CHAR(1)
	,promo_id       NUMBER(6)
	,quantity_sold  NUMBER(3)
	,amount_sold    NUMBER(10,2)
)
PARTITION BY LIST (channel_id)
(
	PARTITION even_channels VALUES (2,4),
	PARTITION odd_channels VALUES (3,9)
);
CREATE TABLE hash_sales
(
	prod_id       NUMBER(6) ,
	cust_id       NUMBER ,
	time_id       DATE ,
	channel_id    CHAR(1) ,
	promo_id      NUMBER(6) ,
	quantity_sold NUMBER(3) ,
	amount_sold   NUMBER(10,2)
)
PARTITION BY HASH(prod_id)
PARTITIONS 2;
CREATE TABLE time_range_sales
(
	prod_id       NUMBER(6) ,
	cust_id       NUMBER ,
	time_id       DATE ,
	channel_id    CHAR(1) ,
	promo_id      NUMBER(6) ,
	quantity_sold NUMBER(3) ,
	amount_sold   NUMBER(10,2)
)
PARTITION BY RANGE(time_id)
(
	PARTITION SALES_1998 VALUES LESS THAN (TO_DATE('2001 01 01','YYYY MM DD')),
	PARTITION SALES_1999 VALUES LESS THAN (TO_DATE('2011 01 01','YYYY MM DD')),
	PARTITION SALES_2000 VALUES LESS THAN (TO_DATE('2021 01 01','YYYY MM DD')),
	PARTITION SALES_2001 VALUES LESS THAN (TO_DATE('2031 01 01','YYYY MM DD'))
);
ALTER TABLE test_table ADD col3 NUMBER;
ALTER TABLE test_table MODIFY col1 VARCHAR2(20);
ALTER TABLE products MODIFY ( count VISIBLE );
ALTER TABLE employees ADD 
( 
	CONSTRAINT emp_emp_id_pk PRIMARY KEY (employee_id) , 
	CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments , 
	CONSTRAINT emp_job_fk FOREIGN KEY (job_id) REFERENCES jobs (job_id) , 
	CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) REFERENCES employees 
);
SELECT ROWID FROM employees WHERE employee_id = 100;
select lcd from bdl_workday_table where rownum<30;
UPDATE employees
SET hire_date   = TO_DATE('1998 05 20','YYYY MM DD')
WHERE last_name = 'Hunold';
INSERT INTO plants VALUES
(2, 'Amaryllis');
RENAME TABLE01 to TABLE02;
DROP TABLE plants;
--**************************************************
--*    PROCEDURE
--**************************************************
CREATE OR REPLACE PROCEDURE test_proc
AS
BEGIN
 FOR x IN ( SELECT col1, col2 FROM test_table )
 LOOP
   -- process data
   NULL;
 END LOOP;
END;
EXECUTE test_proc;
--**************************************************
--*    INDEX
--**************************************************
CREATE INDEX ord_customer_ix ON orders (customer_id);
CREATE INDEX emp_name_dpt_ix ON hr.employees
(
	last_name ASC,
	department_id DESC
);
CREATE BITMAP INDEX employees_bm_idx ON employees (jobs.job_title) 
FROM employees, jobs 
WHERE employees.job_id = jobs.job_id;
CREATE INDEX emp_fname_uppercase_idx ON employees(UPPER(first_name));
--**************************************************
--*    VIEW
--**************************************************
CREATE VIEW staff AS
SELECT employee_id,
  last_name,
  job_id,
  manager_id,
  department_id
FROM employees;
--**************************************************
--*    SEQUENCE
--**************************************************
CREATE SEQUENCE customers_seq 
	START WITH 1000 INCREMENT BY 1 
NOCACHE 
NOCYCLE;
CREATE SYNONYM EMPL FOR EMPLOYEES;
--**************************************************
--*    Transaction control
--**************************************************
SET TRANSACTION NAME 'Update salaries';
SAVEPOINT before_salary_update;
UPDATE employees SET salary =9100 WHERE employee_id=1234;
ROLLBACK TO SAVEPOINT before_salary_update;
UPDATE employees SET salary =9200 WHERE employee_id=1234;
COMMIT COMMENT 'Updated salaries';
--**************************************************
--*    Session control
--**************************************************
SET ROLE NONE;
ALTER SESSION
SET NLS_DATE_FORMAT = 'YYYY MM DD HH24:MI:SS';
--**************************************************
--*    System control
--**************************************************
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM KILL SESSION '39, 23';
--**************************************************
--*    Trigger
--**************************************************
CREATE OR REPLACE TRIGGER lineitems_trigger AFTER
  INSERT OR
  UPDATE OR
  DELETE ON lineitems 
  FOR EACH ROW 
BEGIN 
IF (INSERTING OR UPDATING) THEN
  UPDATE orders
  SET line_items_count = NVL(line_items_count,0)+1
  WHERE order_id       = :new.order_id;
END IF;
IF (DELETING OR UPDATING) THEN
  UPDATE orders
  SET line_items_count = NVL(line_items_count,0)-1
  WHERE order_id       = :old.order_id;
END IF;
END;
--**************************************************
--*    SQLPlus
--**************************************************
COLUMN OBJECT_NAME FORMAT A25;
--**************************************************
--*    模糊查询
--**************************************************
--SELECT * FROM DICTIONARY WHERE TABLE_NAME LIKE 'DBA\_%' ESCAPE '\';
--**************************************************
--*    常用函数
--**************************************************
SQL> select ascii(A) A,ascii(a) a,ascii(0) zero,ascii( ) space from dual;
SQL> select chr(54740) zhao,chr(65) chr65 from dual;
SQL> select concat(010-,88888888)||转23 高乾竞电话 from dual;
SQL> select initcap(smith) upp from dual;
SQL> select instr(oracle traning,ra,1,2) instring from dual;
SQL> select name,length(name),addr,length(addr),sal,length(to_char(sal)) from gao.nchar_tst;
SQL> select lower(AaBbCcDd)AaBbCcDd from dual;
SQL> select upper(AaBbCcDd) upper from dual;
SQL> select lpad(rpad(gao,10,*),17,*)from dual;
SQL> select ltrim(rtrim( gao qian jing , ), ) from dual;
SQL> select substr(13088888888,3,8) from dual;
SQL> select replace(he love you,he,i) from dual;
SQL> create table table1(xm varchar(8));
	insert into table1 values(weather);
	insert into table1 values(wether);
	insert into table1 values(gao);
	select xm from table1 where soundex(xm)=soundex(weather);
SQL> select abs(100),abs(-100) from dual;
SQL> select acos(-1) from dual;
SQL> select asin(0.5) from dual;
SQL> select atan(1) from dual;
SQL> select ceil(3.1415927) from dual;
SQL> select cos(-3.1415927) from dual;
SQL> select cosh(20) from dual;
SQL> select exp(2),exp(1) from dual;
SQL> select floor(2345.67) from dual;
SQL> select ln(1),ln(2),ln(2.7182818) from dual;
SQL> select log(2,1),log(2,4) from dual;
SQL> select mod(10,3),mod(3,3),mod(2,3) from dual;
SQL> select power(2,10),power(3,3) from dual;
SQL> select round(55.5),round(-55.4),trunc(55.5),trunc(-55.5) from dual;
SQL> select sign(123),sign(-100),sign(0) from dual;
SQL> select sin(1.57079) from dual;
SQL> select sin(20),sinh(20) from dual;
SQL> select sqrt(64),sqrt(10) from dual;
SQL> select tan(20),tan(10) from dual;
SQL> select tanh(20),tan(20) from dual;
SQL> select trunc(124.1666,-2) trunc1,trunc(124.16666,2) from dual;
SQL> select to_char(add_months(to_date(199912,yyyymm),2),yyyymm) from dual;
SQL> select to_char(add_months(to_date(199912,yyyymm),-2),yyyymm) from dual;
SQL> select to_char(sysdate,yyyy.mm.dd),to_char((sysdate)+1,yyyy.mm.dd) from dual;
SQL> select last_day(sysdate) from dual;
SQL> select months_between(19-12月-1999,19-3月-1999) mon_between from dual;
SQL> select months_between(to_date(2000.05.20,yyyy.mm.dd),to_date(2005.05.20,yyyy.mm.dd)) mon_betw from dual;
SQL> select to_char(sysdate,yyyy.mm.dd hh24:mi:ss) bj_time,to_char(new_time(sysdate,PDT,GMT),yyyy.mm.dd hh24:mi:ss) los_angles from dual;
SQL> select next_day('18-5月-2001','星期五') next_day from dual;
SQL> select to_char(sysdate,dd-mm-yyyy day) from dual;
SQL> select to_char(trunc(sysdate,hh),yyyy.mm.dd hh24:mi:ss) hh, to_char(trunc(sysdate,mi),yyyy.mm.dd hh24:mi:ss) hhmm from dual;
SQL> select rowid,rowidtochar(rowid),ename from scott.emp;
SQL> select convert(strutz,we8hp,f7dec) "conversion" from dual;
SQL> select to_char(sysdate,yyyy/mm/dd hh24:mi:ss) from dual;
SQL> select to_multi_byte(高) from dual;
SQL> select to_number(1999) year from dual;
SQL> insert into file_tb1 values(bfilename(lob_dir1,image1.gif));
SQL> select greatest(AA,AB,AC) from dual;
SQL> select greatest(啊,安,天) from dual;
SQL> select least(啊,安,天) from dual;
SQL> select username,user_id from dba_users where user_id=uid;
SQL> select user from dual;
SQL> select userenv(isdba) from dual;
SQL> select userenv(isdba) from dual;
SQL> select userenv(sessionid) from dual;
SQL> select userenv(entryid) from dual;
SQL> select userenv(instance) from dual;
SQL> select userenv(language) from dual;
SQL> select userenv(lang) from dual;
SQL> select userenv(terminal) from dual;
SQL> select vsize(user),user from dual;
SQL> create table table3(xm varchar(8),sal number(7,2));
	insert into table3 values(gao,1111.11);
	insert into table3 values(gao,1111.11);
	insert into table3 values(zhu,5555.55);
	commit;
	select avg(distinct sal) from gao.table3;
	select avg(all sal) from gao.table3;
SQL> select max(distinct sal) from scott.emp;
SQL> select min(all sal) from gao.table3;
SQL> select stddev(sal) from scott.emp;
SQL> select stddev(distinct sal) from scott.emp;
SQL> select variance(sal) from scott.emp;
SQL> select deptno,count(*),sum(sal) from scott.emp group by deptno;
SQL> select deptno,count(*),sum(sal) from scott.emp group by deptno having count(*)>=5;
SQL> select deptno,count(*),sum(sal) from scott.emp having count(*)>=5 group by deptno ;
SQL> select deptno,ename,sal from scott.emp order by deptno,sal desc;
SQL> select  (case  when  DUMMY='X'  then  0  else  1  end)  as  flag  from  dual;
SQL> case col 
		when 'a' then 1
		when 'b' then 2
	else 0 end
SQL> case when score <60 then 'd'
		when score >=60 and score <70 then 'c'
		when score >=70 and score <80 then 'b'
	else 'a' end