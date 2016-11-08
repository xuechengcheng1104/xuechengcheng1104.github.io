
##################################################
#import error: output directory already exists
##################################################
--delete-target-dir #add this option
##################################################
#import : 数据格式问题
##################################################
hive中以string类型存储，遇日期比较问题用to_date()转换
##################################################
#export example
##################################################
#excute this script
#+ ./scriptname 2016-09-23 jdbc:mysql://10.31.224.103:3907/cfbbi deployop paic1234 queue02
#!/bin/bash
set -e
txdate=$1
connect=$2
username=$3
password=$4
queue=$5

#1 export data from hive to hdfs directory
hvie -e "
set mapred.job.queue.name=${queue};
insert overwrite directory '/apps-data/hduser0301/xt_trapp_safe/workdmay_table'
select to_date(DATEVALUE), DATEWEEK, DATEFLAG, FCU, to_date(FCD), LCU, to_date(LCD), DEALFLAG
from xt_trapp_safe.workday_table
where to_date(lcd)='${txdate}'
"
#2 truncate table workday_table
sqoop eval \
-Dmapred.job.queue.name=${queue} \
--connect ${connect} \
--username ${username} \
--password ${password} \
-e "truncate table cfbbi.workday_table";
#3 export directory data to table workday_table
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

##################################################
#import example
##################################################
#excute this script: ./scriptname 10.31.11.83:1531:t2tdw HDPSQP HDPSQP 2016-09-21 2016-10-22
#!/bin/bash
tdw_db_url=$1
tdw_db_username=$2
tdw_db_password=$3
nominal_date=$4
end_date=$5

sqoop import \
-Dmapred.job.queue.name="queue02" \
--connect jdbc:oracle:thin:@${tdw_db_url} \
--username ${tdw_db_username} \
--password ${tdw_db_password} \
--table "tdwdata.BDL_WORKDAY_TABLE" \
--columns "DATEVALUE, DATEWEEK, DATEFLAG, FCU, FCD, LCU, LCD, DEALFLAG" \
--where "
to_date(to_char(LCD, 'yyyy-mm-dd'), 'yyyy-mm-dd') >= to_date('${nominal_date}', 'yyyy-mm-dd') 
and to_date(to_char(LCD, 'yyyy-mm-dd'), 'yyyy-mm-dd') >= to_date('${end_date}', 'yyyy-mm-dd')
"
-m 1 \
--fields-terminated-by "\001" \
--lines-terminated-by "\n" \
--hive-drop-import-delime \
--null-string "\\\\N" \
--null-non-string "\\\\N" \
--hive-import \
--delete-target-dir \
--hive-overwrite \
--hive-table xt_trapp_safe.WORKDAY_TABLE