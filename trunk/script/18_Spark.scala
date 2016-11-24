
//#-------------------------------------------------
//#leftOuterJoin
//#-------------------------------------------------
val rdd1 = sc.makeRDD(Array(("A", "1"),("B", "2"),("C", "3")), 2)
val rdd2 = sc.makeRDD(Array(("A", "a"),("C", "c"),("D", "d")), 2)
val rdd3 = sc.makeRDD(Array(("A", "4"),("C", "5"),("D", "6")), 2)
rdd1.leftOuterJoin(rdd2).leftOuterJoin(rdd3).collect.foreach(println)
rdd1.leftOuterJoin(rdd2).leftOuterJoin(rdd3).repartition(1).saveAsTextFile("output/output.txt")
//#-------------------------------------------------
//#Key-Value Pairs
//#-------------------------------------------------
val distFile = sc.textFile("data.txt")
val pairs = distFile.map(s => (s.length, 1))
val counts = pairs.reduceByKey((a, b) => a + b) // the same as SQL group by then count()
counts.foreach(println)
//#-------------------------------------------------
//#RDD输出
//#-------------------------------------------------
val distFile = sc.textFile("data.txt")
distFile.foreach(println)
distFile.collect().foreach(println) // fetches the entire RDD to a single machine
distFile.take(30).foreach(println)  // then same as SQL limit 30
counts.saveAsTextFile("output.txt")
counts.coalesce(1,true).saveAsTextFile("output.txt")
counts.repartition(1).saveAsTextFile("output.txt") // the same as the statement above
//#-------------------------------------------------
//#IDEA spark enviroment setup
//#-------------------------------------------------
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
colone "https://github.com/srccodes/hadoop-common-2.2.0-bin" 取文件winutils.exe到hadoop的bin目录
//#-------------------------------------------------
//#SparkContext
//#-------------------------------------------------
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
//#-------------------------------------------------
//#数据源
//#-------------------------------------------------
val data = Array(1, 2, 3, 4, 5)
val distData = sc.parallelize(data)
println(distData.reduce((a, b) => a + b))
//#-------------------------------------------------
//#文件源
//#-------------------------------------------------
val distFile = sc.textFile("data.txt")
println(distFile.map(s => s.length).reduce((a, b) => a + b))
//#-------------------------------------------------
//#define user function
//#-------------------------------------------------
val distFile = sc.textFile("data.txt")
val field = "Hello "
def doStuff(rdd: RDD[String]): RDD[String] = { rdd.map(x => field + x) }
doStuff(distFile).foreach(println)
//#-------------------------------------------------
//#accumulator
//#-------------------------------------------------
val accum = sc.accumulator(0)
sc.parallelize(Array(1, 2, 3, 4)).foreach(x => accum += x)
println(accum.value)
//#-------------------------------------------------
//#StreamingContext
//#-------------------------------------------------
package main.scala.Test
import org.apache.spark.SparkConf
import org.apache.spark.rdd.RDD
import org.apache.spark.streaming._
import scala.collection.mutable
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
//#-------------------------------------------------
//#Socket数据源
//#-------------------------------------------------
val lines = ssc.socketTextStream("localhost", 9999)
val words = lines.flatMap(_.split(" "))
val pairs = words.map(word => (word, 1))
val wordCounts = pairs.reduceByKey(_ + _)  // the same as SQL group by then count()
wordCounts.foreachRDD(rdd => rdd.foreach(println))
//#-------------------------------------------------
//#RDD队列数据源
//#-------------------------------------------------
val rddQueue = new mutable.SynchronizedQueue[RDD[Int]]()
val inputStream = ssc.queueStream(rddQueue)
val mappedStream = inputStream.map(x => (x % 10,1))
val reduceStream = mappedStream.reduceByKey(_ + _)
reduceStream.print
ssc.start()
for(i <- 1 to 30){
  rddQueue += ssc.sparkContext.makeRDD(1 to 100, 2)   //创建RDD，并分配两个核数
  Thread.sleep(1000)
}
ssc.stop()
//#-------------------------------------------------
//#累计更新键值
//#-------------------------------------------------
//定义状态更新函数
val updateFunc = (values: Seq[Int], state: Option[Int]) => {
	val currentCount = values.foldLeft(0)(_ + _)
	val previousCount = state.getOrElse(0)
	Some(currentCount + previousCount)
}
ssc.checkpoint("file:/E:/00_FileTree/27_Spark/output/")    //设置检查点，存储位置是当前目录，检查点具有容错机制
val lines = ssc.socketTextStream("localhost", 9999)
val words = lines.flatMap(_.split(" "))
val pairs = words.map(word => (word, 1))
val stateDstream = pairs.updateStateByKey[Int](updateFunc)
stateDstream.foreachRDD(rdd => rdd.foreach(println))
