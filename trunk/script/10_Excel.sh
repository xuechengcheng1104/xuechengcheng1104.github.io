﻿
#-------------------------------------------------
#    两个集合的差集
#-------------------------------------------------
=IF(COUNTIF(A:A,B1)>=2, 1, 0)
#-------------------------------------------------
#    常用函数
#-------------------------------------------------
TRIM、CLEAN函数
LEFT、RIGHT函数
SUMIF(range，criteria，sum_range)
SUBTOTAL(function_num,Range)
SUMPRODUCT(array1, [array2], [array3], ...)
IF(logical_test, value_if_true,  [value_if_false])
IFERROR(value, value_if_error)
COUNTIF(range,criteria)
COUNTIF(B$2:B2,B2)
NETWORKDAYS(start_date, end_date, [holidays])
WORKDAY(start_date, days, [holidays])
VLOOKUP(lookup_value,table_array,col_index_num , range_lookup)
#-------------------------------------------------
#    定位到某表区域中某行（动态匹配）某列（1）， 并取出值
#-------------------------------------------------
INDEX($A$2:$D$15,MATCH(F3,$B$2:$B$15,0),4)
注：选择的区域之所以都加了“$”是为了让这个区域“绝对引用”，不管我怎么下拉，这个区域都是固定的
#-------------------------------------------------
#    将日期转化为文本类型，然后和其他单元格连接
#-------------------------------------------------
&TEXT(C2， "yyyy-mm-dd")&
#-------------------------------------------------
#    如果字段长度小于30，取其字段值
#-------------------------------------------------
=IF(LEN(B1)<30, B1, 0)
#-------------------------------------------------
#    截取字符串
#-------------------------------------------------
=IFERROR(LEFT(B1, IFERROR(FINDB(">>/",B1, 1), 0)-1), 0)
#-------------------------------------------------
#    分组计数实现
#-------------------------------------------------
第一列：原数据
第二列：DISTINCT 之后数据，菜单 / 数据 / 筛选（高级） / 选择不重复
第三列：COUNTIF($A$2：$A$287， C2)
#-------------------------------------------------
#    分组合计SUM()
#-------------------------------------------------
=SUMIF( $I$2:$J$61 ， K2， $J$2:$J$61 )
#-------------------------------------------------
#    excel SQL精确查询
#-------------------------------------------------
Step 1: 选择区域 / 右击 / 定义名称
Step 2: 数据 / 自其他来源 / 来自Microsoft Query
#-------------------------------------------------
#    excel 公式转文本
#-------------------------------------------------
选中区域 / 右击选择性粘贴 / 数值
#-------------------------------------------------
#    如果单元格值存在于某个区域的话，就取这个单元格，否则置null
#-------------------------------------------------
=","&(COUNTIF($G$1:$G$10, A1)=1, A1, "null")