
##################################################
#将unix时间戳转化为日期格式
##################################################
date -d @1479304477
##################################################
#杀死进程
##################################################
kill -9 4560
##################################################
#awk
##################################################
cat /etc/passwd | awk -F ':' '/hadoop/' #partern
cat /etc/passwd | awk -F ':' '$0 ~ /hadoop/{print $0}' #the same as the above command
cat /etc/passwd | awk -F ':' '$3 ~ /1000/{print $1, $2, $3, $4}' #the match operator
cat /etc/passwd | awk -F ':' '$3 == 1000 {print $1, $2, $3, $4}' #类SQL查询'select ... where ...'
cat /etc/passwd | awk -F ':' '$1 ~ /sshd/,/hadoop/' #区间
cat /etc/passwd | awk -F ':' '{print $1}' #action
cat /etc/passwd | awk -F ':' '/bash/{print $1, $2, $3}' #partern-action
cat /etc/passwd | awk -F ':' '{printf "%-15s|%-15s|%-15d|\n", $1, $2, $3}' #格式化输出
cat /etc/passwd | awk -F ':' '{max=($3 > $4) ? $3 : $4; print $3, $4, max}' #more statement in one action
cat /etc/passwd | awk -F ':' '{printf "%-3s|%-15s|%-15s|%-15d|\n", NR, $1, $2, $3}' #record序号
cat /etc/passwd | awk -F '[ :\t/]' '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11}' #special mutil seprator
date | awk '{ print "Month: ", $2 "\nYear: ", $6 }' #逗号隔开变量（常量），缺省空格就是连接字符串
awk  'BEGIN{OFMT="%.2f"; OFS=","; print 1.2456789, 1.3456}' #设置环境变量，控制输出数值格式
awk 'BEGIN{ "date" | getline d; print d}'
cat awkfile
	BEGIN{
		FS=":"
		OFS="\t"
		ORS="\n"
		OFMT="%.2f"
	}
	$1 ~ /root/{
	        print $0, "\n"
	}
	{
		sub(/hadoop/, "xcc", $1)
	    count++
		name[x++]=$1
		count2[$7]++ #the same as SQL 'SELECT column1, COUNT(*) FROM tablename GROUP BY column1
		if($1 !~ /root/){
		        printf "|%-15s|%-15s|%-15d|\n", $1, $2, $3
		}
		else{
			next #skip this record
		}
	}
	END{
		print "the variable from outside month: ", month, "year: ", year
		if(count>3){
			print "bash was found more than 3 times."
		}
		else if(count=3){
			print "bash was found equal to 3 times."
		}
		else if(count<3){
			print "bash was found less than 3 times."
		}
		else{
			print "bash was found " count " times!"
		}
		for(i=0; i<NR; i++){
			print i, name[i] #delete (line[x]) this function 'delete' can be used well
		}
		for(i in name){
			print i, name[i] #the printout is random
		}
		for(j in count2){
			if(count2[j]<2){
				delete count2[j] #the same as SQL 'GROUP BY xolumn1 HAVING count(*)>=2
			}
		}
		for(j in count2){
			print j, count2[j] #the printout is random
		}
		for ( i=0; i < ARGC; i++ ){
			printf("argv[%d] is %s\n", i, ARGV[i]) #the variables input from command line
		}
		"date" | getline d ; split( d, mon, " ") ; print mon[2], mon[6]
		sys_command="ls -l ./"; system (sys_command)
		exit(55) #give variable $? value '55' indicate no success
	}
cat /etc/passwd | awk -f awkfile -v month=4 -v year=2004
cat awkfile
	#!/bin/sh
	cat /etc/passwd | awk -F ':' '/bash/{printf "|%-15s|%-15s|%-15d|\n", $1, $2, $3; printf "|%-15s\n", $1}'
./awkfile
##################################################
#格式化输出
##################################################
printf "|%-20s|%-20s|%-20.2f|\n" "Jody" "Savage" 28


##################################################
#    整理文本格式
##################################################
replace '^([a-z]^)^p' with '^1 '
replace ',^p' with ', '
replace '-^p' with '-'
replace ',"^p' with '," '
replace ',"^p' with '," '
replace '%' with '  '
##################################################
#引号 & 变量
##################################################
grep -i '$LOGNAME' datafile #不允许变量替换
grep -i "$LOGNAME" datafile #允许变量替换
##################################################
#Regular Expression
##################################################
#awk
^          /^love/                    #Beginning-of-line anchor
$          /love$/                    #End-of-line anchor
.          /l..e/                     #Matches one character
*          / *love/                   #Matches zero or more of the preceding characters
[ ]        /[Ll]ove/                  #Matches one in the set
[x–y]      /[A–Z]ove/                 #Matches one character within a range in the set
[^ ]       /[^A–Z]/                   #Matches one character not in the set
\          /love\./                   #Used to escape a metacharacter
\<         /\<love/                   #Beginning-of-word anchor
\>         /love\>/                   #End-of-word anchor
\(..\)     /\(love\)able \1er/        #Tags match characters to be used later
x\{m,n\}    o\{5,10\}                 #Repetition of character x, m times, at least m times, at least m and not more than n times[a]（omit',n'）
+          '[a–z]+ove'                #Matches one or more of the characters preceding the + sign
?          'lo?ve'                    #Matches zero or one of the preceding characters
a|b        'love|hate'                #Matches either a or b
( )        'love(able|ly)' '(ov)+'    #Groups characters
\b                                    #the same as \< and  \>
\w                                    #the same as [a–zA–Z0–9_]
\W                                    #the same as [^a–zA–Z0–9_]
#ultraedit
%[ ^t]+              #替换行首空格
--*$                 #替换SQL文本中的注释
%                    #匹配行的开始 - 显示搜索字符串必须在行的开始，但是在所选择的结果字符串中不包括任何行终止字符。
$                    #匹配行尾 - 显示搜索字符串必须在行尾，但是在所选择的结果字符串中不包括任何行终止字符。
?                    #除了换行符以外匹配任何单个的字符
*                    #除了换行符匹配任何数量的字符和数字
+                    #前一字符匹配一个或多个，但至少要出现一个
++                   #前一字符匹配零个或多个，但至少要出现一个
^b                   #匹配一个分页
^p                   #匹配一个换行符(CR/LF)(段)(DOS文件)
^r                   #匹配一个换行符(CR 仅仅)(段)(MAC 文件)
^n                   #匹配一个换行符 ( LF 仅仅 )( 段 )( UNIX 文件 )
^t                   #匹配一个标签字符TAB
[]                   #匹配任何单个的字符，或在方括号中的范围
^{A^}^{ B^}          #匹配表达式A或 B
^                    #重载其后的正规表达式字符
^(^)                 #括或标注为用于替换命令的表达式
##################################################
#vim 替换
##################################################
:1,$s/tom/David/g #replace the characters string
:1,$s/\<[Tt]om\>/David/g #replace the worlds with David
vim CTRL-S 锁住后，CTRL-Q解锁
##################################################
#shell scripts - 脚本依赖检查
##################################################
#be carefule! file input.q must be UNIX-UTF8
#!/bin/bash
function depend()
{
	v1_array=($(cat ./input.q))
	rm ./input.q
	touch ./input.q
	v2_length=${#v1_array[*]}
	for((i=0; i<$v2_length;i++));
	do
		v3_array=($(grep -li "${v1_array[$i]}\>" ./D_L/*))
		v4_length=${#v3_array[*]}
		for((j=0; j<$v4_length; j++));
		do
			v5_string=${v3_array[$j]}
			v5_string=${v5_string##*/}
			v5_string=${v5_string%.*}
			if grep -i "^$v5_string$" ./inputtotal.q;
			then
				echo exists
			else
				echo $v5_string >> ./input.q
				echo $v5_string >> ./inputtotal.q
			fi
			echo ${v1_array[$i]}'&'$v5_string >> ./output.q
		done
	done
}
echo '' > ./inputtotal.q
echo '' > ./output.q
v7_inputnull=./input.q
v6_iterator=1
while [ -s $v7_inputnull ]
do
	echo 'the following is the number '$v6_iterator' level' >> ./output.q
	let v6_iterator+=1
	depend
done
echo 'analyze successed!'
##################################################
#shell scripts - 字符串截取
##################################################
#!/bin/bash
str='http://www.baidu.com/cut-string.html'
str='http://www.baidu.com/cut-string.html'
echo ${str#*//}        #start from left, delete the shortest matched partern like '*//'
echo ${str##*/}        #start from left, delete the longest matched partern like '*/'
echo ${str%/*}         #start from right, delete the shortest matched partern like '/*'
echo ${str%%/*}        #start from right, delete the longest matched partern like '/*'
echo ${var:0:5}        #0 represent the starting position, 5 represent the length 
echo ${var:7}          #starting from the number eight position, until the endness
echo ${str:0-15:10}    #starting from the number sisteen position (reverse direction), the length is 10
echo ${str:0-4}        #like the above example
##################################################
#多行注释
##################################################
:<<!
	...
!
##################################################
#文件编码导致执行失败
##################################################
UNIX下可执行文件必须是UNIX-UTF8格式
