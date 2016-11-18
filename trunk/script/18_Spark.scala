
//##################################################
//#IDEA spark enviroment setup
//##################################################
//enviroment 1
jdk 1.7
scala 2.10
spark 1.4
//enviroment 2
jdk 1.8
scala 2.11
spark 2.0
hadoop 2.6
解压hadoop配置HADOOP_HOME重启电脑，或者代码中添加 
	System.setProperty("hadoop.home.dir", "E:\\00_FileTree\\16_TempFile\\hadoop-2.6.4");
克隆https://github.com/srccodes/hadoop-common-2.2.0-bin 取文件winutils.exe到hadoop的bin目录
//##################################################
//#init SparkContext
//##################################################
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}
object scala {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("Simple Application").setMaster("local[2]") //two working thread
    val sc = new SparkContext(conf)
    //...
    sc.stop()
  }
}
//##################################################
//#Array
//##################################################
val data = Array(1, 2, 3, 4, 5)
val distData = sc.parallelize(data)
println(distData.reduce((a, b) => a + b))
//##################################################
//#File read
//##################################################
val distFile = sc.textFile("data.txt")
println(distFile.map(s => s.length).reduce((a, b) => a + b))
//##################################################
//#define user function
//##################################################
val distFile = sc.textFile("data.txt")
val field = "Hello "
def doStuff(rdd: RDD[String]): RDD[String] = { rdd.map(x => field + x) }
doStuff(distFile).foreach(println)
//##################################################
//#accumulator
//##################################################
val accum = sc.accumulator(0)
sc.parallelize(Array(1, 2, 3, 4)).foreach(x => accum += x)
println(accum.value)
//##################################################
//#init SparkSteaming
//##################################################
package main.scala.Test
import org.apache.spark.SparkConf
import org.apache.spark.streaming._
object scala {
  def main(args: Array[String]){
    System.setProperty("hadoop.home.dir", "E:\\00_FileTree\\16_TempFile\\hadoop-2.6.4")
    val conf = new SparkConf().setAppName("Simple Application").setMaster("local[2]")
    val ssc = new StreamingContext(conf, Seconds(1))
    //...
    ssc.start()
    ssc.awaitTermination()
  }
}
//##################################################
//#Socket Streaming
//##################################################
val lines = ssc.socketTextStream("localhost", 9999)
val words = lines.flatMap(_.split(" "))
val pairs = words.map(word => (word, 1))
val wordCounts = pairs.reduceByKey(_ + _)
wordCounts.print()
