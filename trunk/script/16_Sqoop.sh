
#-------------------------------------------------
#sqoop 从oracle库导数据到hive
#-------------------------------------------------
sqoop import \
-Dmapred.job.queue.name="queue02" \
--connect jdbc:oracle:thin:@${tdw_db_url} \
--username ${tdw_db_username} \
--password ${tdw_db_password} \
--table "tdwdata.BDL_WORKDAY_TABLE" \
--columns "DATEVALUE, DATEWEEK, DATEFLAG, FCU, FCD, LCU, LCD, DEALFLAG" \ #字段名要大写
--where "
to_date(to_char(LCD, 'yyyy-mm-dd'), 'yyyy-mm-dd') >= to_date('${nominal_date}', 'yyyy-mm-dd')
and to_date(to_char(LCD, 'yyyy-mm-dd'), 'yyyy-mm-dd') >= to_date('${end_date}', 'yyyy-mm-dd')
"
-m 1 \
--fields-terminated-by "\001" \
--lines-terminated-by "\n" \
--hive-drop-import-delime \ #去掉hive默认的分隔符
--null-string "\\\\N" \
--null-non-string "\\\\N" \
--hive-import \
--delete-target-dir \
--hive-overwrite \
--hive-table xt_trapp_safe.WORKDAY_TABLE
#-------------------------------------------------
#sqoop shell脚本中做hive处理
#-------------------------------------------------
hvie -e "
set mapred.job.queue.name=${queue};
insert overwrite directory '/apps-data/hduser0301/xt_trapp_safe/workdmay_table'
select
	to_date(DATEVALUE),
	DATEWEEK,
	DATEFLAG,
	FCU,
	to_date(FCD),
	LCU,
	to_date(LCD),
	DEALFLAG
from xt_trapp_safe.workday_table
where to_date(lcd)='${txdate}'
"
#-------------------------------------------------
#sqoop 链接mysql库执行语句
#-------------------------------------------------
sqoop eval \
-Dmapred.job.queue.name=${queue} \
--connect ${connect}
--username ${username}
--password ${password}
-e "
truncate table cfbbi.workday_table_tmp;
"
#-------------------------------------------------
#sqoop 从hive库导数据到mysql库
#-------------------------------------------------
sqoop export \
-Dmapred.job.queue.name=${queue} \
--connect ${connect} \
--username ${username} \
--password ${password} \
--export-dir '/apps-data/hduser0301/xt_trapp_safe/workday_table' \
-verbose \
--table workday_table \
--columns DATEVALUE, DATEWEEK, DATEFLAG, FCU, FCD, LCU, LCD, DEALFLAG \
--input-fields-terminated-by "\001" \
--input-lines-terminated-by "\n" \
--input-hive-drop-import-delime \
--input-null-string "\\\\N" \
--input-null-non-string "\\\\N" \
#-------------------------------------------------
#import error: output directory already exists
#-------------------------------------------------
--delete-target-dir #add this option
#-------------------------------------------------
#import : 数据格式问题
#-------------------------------------------------
hive中以string类型存储，遇日期比较问题用to_date()转换