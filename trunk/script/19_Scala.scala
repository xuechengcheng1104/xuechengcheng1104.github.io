
//#-------------------------------------------------
//#operations on file
//#-------------------------------------------------
import scala.io.Source
object Other {
  def main(args: Array[String]): Unit = {
    val v_string: StringBuilder = new StringBuilder("")
    val localfile = Source.fromFile("input/people.json", "UTF-8")
    for (line <- localfile.getLines()) {
      if (line.indexOf("--") == -1) {
        v_string.append(line)
        v_string.append(" ")
      }
    }
    println(v_string.toString)
    localfile.close()
  }
}
//#-------------------------------------------------
//#对List遍历
//#-------------------------------------------------
def widthOfLength(s: String) = s.length
if (args.length > 0) {
  val lines = Source.fromFile(args(0)).getLines.toList
  var maxWidth = 0
//or use "lines.reduceLeft( (a, b) => if (a.length > b.length) a else b )"
  for (line <- lines){
    maxWidth = maxWidth.max(widthOfLength(line))
    print(line+":\t")
    println(line.length.toString)
  }
  println(maxWidth)
}
else
  Console.err.println("Please enter filename")
//#-------------------------------------------------
//#模式匹配-函数
//#-------------------------------------------------
def matchTest(x: Int): String = x match {
case 1 => "one"
case 2 => "two"
case _ => "many"
}
println(matchTest(3))
//#-------------------------------------------------
//#模式匹配-样例类
//#-------------------------------------------------
case class Person(name: String, age: Int)
val alice = new Person("Alice", 25)
val bob = new Person("Bob", 32)
val charlie = new Person("Charlie", 32)
for (person <- List(alice, bob, charlie)) {
  person match {
    case Person("Alice", 25) => println("Hi Alice!")
    case Person("Bob", 32) => println("Hi Bob!")
    case Person(name, age) => println("Age: " + age + " year, name: " + name + "?")
  }
}
//#-------------------------------------------------
//#class
//#-------------------------------------------------
class Point(xc: Int, yc: Int) {
  var x: Int = xc
  var y: Int = yc
  def move(dx: Int, dy: Int) {
    x = x + dx
    y = y + dy
    println ("x 的坐标点: " + x);
    println ("y 的坐标点: " + y);
  }
}
val pt = new Point(10, 20);
pt.move(10, 10);
//#-------------------------------------------------
//#正则表达式
//#-------------------------------------------------
import scala.util.matching.Regex
val pattern = "Scala".r
val str = "Scala is Scalable and cool"
println(pattern findFirstIn str)
println((pattern findAllIn str).mkString(","))
println(pattern replaceFirstIn(str, "Java"))

^	        //匹配输入字符串开始的位置。
$	        //匹配输入字符串结尾的位置。
.	        //匹配除"\r\n"之外的任何单个字符。
[...]	    //字符集。匹配包含的任一字符。例如，"[abc]"匹配"plain"中的"a"。
[^...]	    //反向字符集。匹配未包含的任何字符。例如，"[^abc]"匹配"plain"中"p"，"l"，"i"，"n"。
\\A	        //匹配输入字符串开始的位置（无多行支持）
\\z	        //字符串结尾(类似$，但不受处理多行选项的影响)
\\Z	        //字符串结尾或行尾(不受处理多行选项的影响)
re*	        //重复零次或更多次
re+	        //重复一次或更多次
re?	        //重复零次或一次
re{ n}	    //重复n次
re{ n,}
re{ n, m}	//重复n到m次
a|b	        //匹配 a 或者 b
(re)	    //匹配 re,并捕获文本到自动命名的组里
(?: re)	    //匹配 re,不捕获匹配的文本，也不给此分组分配组号
(?> re)	    //贪婪子表达式
\\w	        //匹配字母或数字或下划线或汉字
\\W	        //匹配任意不是字母，数字，下划线，汉字的字符
\\s	        //匹配任意的空白符,相等于 [\t\n\r\f]
\\S	        //匹配任意不是空白符的字符
\\d	        //匹配数字，类似 [0-9]
\\D	        //匹配任意非数字的字符
\\G	        //当前搜索的开头
\\n	        //换行符
\\b	        //通常是单词分界位置，但如果在字符类里使用代表退格
\\B	        //匹配不是单词开头或结束的位置
\\t	        //制表符
\\Q	        //开始引号：\Q(a+b)*3\E 可匹配文本 "(a+b)*3"。
\\E	        //结束引号：\Q(a+b)*3\E 可匹配文本 "(a+b)*3"。
//#-------------------------------------------------
//#正则表达式
//#-------------------------------------------------
// 定义整型 List
val x = List(1,2,3,4)
// 定义 Set
var x = Set(1,3,5,7)
// 定义 Map
val x = Map("one" -> 1, "two" -> 2, "three" -> 3)
// 创建两个不同类型元素的元组
val x = (10, "Runoob")
// 定义 Option
val x:Option[Int] = Some(5)
//#-------------------------------------------------
//#函数
//#-------------------------------------------------
def addInt( a:Int, b:Int ) : Int = {
  var sum:Int = 0
  sum = a + b
  return sum
}
def printMe( ) : Unit = {
  println("Hello, Scala!")
}
//#-------------------------------------------------
//#闭包
//#-------------------------------------------------
var factor = 3  
val multiplier = (i:Int) => i * factor
println( "muliplier(1) value = " +  multiplier(1) )  
println( "muliplier(2) value = " +  multiplier(2) )
//#-------------------------------------------------
//#迭代器
//#-------------------------------------------------
val it = Iterator("Baidu", "Google", "Runoob", "Taobao")
while (it.hasNext){
  println(it.next())
}
//#-------------------------------------------------
//#格式化输出
//#-------------------------------------------------
var floatVar = 12.456
var intVar = 2000
var stringVar = "菜鸟教程!"
var fs = printf("浮点型变量为 " + "%f, 整型变量为 %d, 字符串为 " + " %s", floatVar, intVar, stringVar)
println(fs)
//#-------------------------------------------------
//#配置文件数据获取方式
//#-------------------------------------------------
import java.io.{File, FileInputStream}
import java.util.Properties
object Other {
  def main(args: Array[String]): Unit = {
    val v_config = new Properties()
    val v_url_prefix = System.getProperty("user.dir")
    val v_configure_url = v_url_prefix + File.separator + "input" + File.separator + "configure.properties"
    v_config.load(new FileInputStream(v_configure_url))
    println(v_configure_url)
    println(v_config.getProperty("username"))
    println(v_config.getProperty("password"))
  }
}
//#-------------------------------------------------
//#时间处理
//#-------------------------------------------------
import java.sql.Date
import java.text.SimpleDateFormat
object Other {
  def main(args: Array[String]): Unit = {
    val v_now = System.currentTimeMillis()
    val v_sdf : SimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd:HH:mm:ss")
    val v_date : String = v_sdf.format(new Date(v_now))
    println(v_now)
    println(new Date(v_now))
    println(v_date)
  }
}
//#-------------------------------------------------
//#日期处理
//#-------------------------------------------------
import java.util.Calendar
object Other {
  def main(args: Array[String]): Unit = {
    val v_now = Calendar.getInstance()
    println(v_now)
    println(v_now.get(Calendar.ERA))
    println(v_now.get(Calendar.YEAR))
    println(v_now.get(Calendar.MONTH))
    println(v_now.get(Calendar.WEEK_OF_YEAR))
    println(v_now.get(Calendar.WEEK_OF_MONTH))
    println(v_now.get(Calendar.DAY_OF_MONTH))
    println(v_now.get(Calendar.DAY_OF_YEAR))
    println(v_now.get(Calendar.DAY_OF_WEEK))
    println(v_now.get(Calendar.DAY_OF_WEEK_IN_MONTH))
    println(v_now.get(Calendar.AM_PM))
    println(v_now.get(Calendar.HOUR))
    println(v_now.get(Calendar.HOUR_OF_DAY))
    println(v_now.get(Calendar.MINUTE))
    println(v_now.get(Calendar.SECOND))
    println(v_now.get(Calendar.MILLISECOND))
    println(v_now.get(Calendar.ZONE_OFFSET))
    println(v_now.get(Calendar.DST_OFFSET))
  }
}




