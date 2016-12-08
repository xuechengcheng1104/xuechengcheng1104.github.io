
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
//#Key-Value Pairs
//#-------------------------------------------------
val distFile = sc.textFile("data.txt")
val pairs = distFile.map(s => (s.length, 1))
val counts = pairs.reduceByKey((a, b) => a + b) // the same as SQL group by then count()
counts.foreach(println)
//#-------------------------------------------------
//#leftOuterJoin
//#-------------------------------------------------
val rdd1 = sc.makeRDD(Array(("A", "1"),("B", "2"),("C", "3")), 2)
val rdd2 = sc.makeRDD(Array(("A", "a"),("C", "c"),("D", "d")), 2)
val rdd3 = sc.makeRDD(Array(("A", "4"),("C", "5"),("D", "6")), 2)
rdd1.leftOuterJoin(rdd2).leftOuterJoin(rdd3).collect.foreach(println)
rdd1.leftOuterJoin(rdd2).leftOuterJoin(rdd3).repartition(1).saveAsTextFile("output/output.txt")
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
val rddQueue = new mutable.Queue[RDD[Int]]()
val inputStream = ssc.queueStream(rddQueue)
inputStream.map(x => (x % 10,1)).reduceByKey(_ + _).print()
inputStream.saveAsTextFiles("output/DStream")
ssc.start()
for(i <- 1 to 30){
  rddQueue += ssc.sparkContext.makeRDD(1 to 100, 2)   //创建RDD，并分配两个核数
  Thread.sleep(1000)
}
ssc.awaitTermination()
//#-------------------------------------------------
//#累计更新键值
//#-------------------------------------------------
//定义状态更新函数
val updateFunc = (values: Seq[Int], state: Option[Int]) => {
	val currentCount = values.foldLeft(0)(_ + _) //累积器
	val previousCount = state.getOrElse(0)
	Some(currentCount + previousCount)
}
ssc.checkpoint("file:/E:/00_FileTree/27_Spark/output/")    //设置检查点，存储位置是当前目录，检查点具有容错机制
val lines = ssc.socketTextStream("localhost", 9999)
val words = lines.flatMap(_.split(" "))
val pairs = words.map(word => (word, 1))
val stateDstream = pairs.updateStateByKey[Int](updateFunc)
stateDstream.foreachRDD(rdd => rdd.foreach(println))
//#-------------------------------------------------
//#SparkContext -> SparkSession
//#-------------------------------------------------
val rdd1 = sc.makeRDD(Array(("A", "1"),("B", "2"),("C", "3")), 2)
val spark = SparkSession.builder.config(rdd1.sparkContext.getConf).getOrCreate()
import spark.implicits._ //隐式转换
rdd1.toDF("word", "code").createOrReplaceTempView("words") // Register the DataFrame as a SQL temporary view
val wordCountsDataFrame = spark.sql("select * from words")
//#-------------------------------------------------
//#init SparkSession
//#-------------------------------------------------
package main.Spark.SQL
import org.apache.spark.sql.SparkSession
object SparkRDD {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder()
      .appName("Simple Application")
      .master("local[2]")
      .config("spark.some.config.option", "some-value")
      .getOrCreate()
    //...
    spark.stop()
  }
}
//#-------------------------------------------------
//#读取json文件，输出DF
//#-------------------------------------------------
val path = "input/data02.txt"
spark.read.json(path).createOrReplaceTempView("Employee")
val EmployeeDF=spark.sql("select * from Employee")
EmployeeDF.printSchema()
EmployeeDF.show()
//#-------------------------------------------------
//#DF操作
//#-------------------------------------------------
wordCountsDataFrame.printSchema()
wordCountsDataFrame.show()
wordCountsDataFrame.select("word").show()
wordCountsDataFrame.select($"word", $"code"+10).show()
wordCountsDataFrame.groupBy($"word").count()show()
wordCountsDataFrame.filter($"code" > 4).show()
//#-------------------------------------------------
//#toDS
//#-------------------------------------------------
case class Person(name: String, age: Long) //放到main函数外面
import spark.implicits._
val caseClassDS = Seq(Person("Andy", 32)).toDS()
caseClassDS.show()
val primitiveDS = Seq(1, 2, 3).toDS()
primitiveDS.map(_ + 1).show()
//#-------------------------------------------------
//#toDF
//#-------------------------------------------------
import spark.implicits._
val peopleDF = spark.sparkContext
  .textFile("input/data01.txt")
  .map(_.split(" "))
  .map(attributes => Person(attributes(0), attributes(1).trim.toInt))
  .toDF()
peopleDF.createOrReplaceTempView("people")
val teenagersDF = spark.sql("SELECT * FROM people")
teenagersDF.show()
teenagersDF.map(teenager => "Name: " + teenager(0)).show()
teenagersDF.map(teenager => "Name: " + teenager.getAs[String]("name")).show()
//#-------------------------------------------------
//#Specifying the Schema
//#-------------------------------------------------
import org.apache.spark.sql.Row
import org.apache.spark.sql.types._
val peopleRDD = spark.sparkContext.textFile("input/data01.txt")
val rowRDD = peopleRDD.map(_.split(" ")).map(attributes => Row(attributes(0), attributes(1).trim))
val schemaString = "name age"
val fields = schemaString.split(" ").map(fieldName => StructField(fieldName, StringType, nullable = true))
val schema = StructType(fields)
val peopleDF = spark.createDataFrame(rowRDD, schema)
peopleDF.createOrReplaceTempView("people")
val results = spark.sql("SELECT * FROM people")
results.show()
//#-------------------------------------------------
//#default source format-parquet
//#-------------------------------------------------
val path = "input/users.parquet"
val usersDF = spark.read.load(path)
usersDF.printSchema()
usersDF.select("name", "favorite_color").show()
usersDF.select("name", "favorite_color").write.save("output/namesAndFavColors.parquet")
//#-------------------------------------------------
//#manully specify format
//#-------------------------------------------------
val path = "input/people.json"
val peopleDF = spark.read.format("json").load(path)
peopleDF.printSchema()
peopleDF.show()
peopleDF.select("name", "age").write.format("parquet").save("output/namesAndAges.parquet")
//#-------------------------------------------------
//#run sql on file
//#-------------------------------------------------
val sqlDF = spark.sql("SELECT * FROM json.`input/ChineseCities.json`")
sqlDF.printSchema()
sqlDF.select("city.area").show()
sqlDF.select("city.area").write.format("json").save("output/namesAndAges.json")
//#-------------------------------------------------
//#partition merge
//#-------------------------------------------------
import spark.implicits._
val squaresDF = spark.sparkContext.makeRDD(1 to 5).map(i => (i, i * i)).toDF("value", "square")
squaresDF.write.parquet("output/data/test_table/key=1")
val cubesDF = spark.sparkContext.makeRDD(6 to 10).map(i => (i, i * i * i)).toDF("value", "cube")
cubesDF.write.parquet("output/data/test_table/key=2")
val mergedDF = spark.read.option("mergeSchema", "true").parquet("output/data/test_table")
mergedDF.printSchema()
mergedDF.show()
//#-------------------------------------------------
//#RDD存放json数据
//#-------------------------------------------------
val otherPeopleRDD = spark.sparkContext.makeRDD("""{"name":"Yin","address":{"city":"Columbus","state":"Ohio"}}""" :: Nil)
otherPeopleRDD.foreach(println)
val otherPeople = spark.read.json(otherPeopleRDD)
otherPeople.printSchema()
otherPeople.select("name","address.city","address.state").show()
//#-------------------------------------------------
//#Spark-Hive SQL
//#-------------------------------------------------
package main.Spark
import org.apache.spark.sql.SparkSession
object SparkSQL {
  case class Record(key: Int, value: String)
  def main(args: Array[String]) {
    val warehouseLocation = "file:\\\\\\E:\\00_FileTree\\27_Spark\\spark-warehouse"  //file:\\\E:\00_FileTree\27_Spark\spark-warehouse
    val spark = SparkSession
      .builder()
      .appName("Simple Application")
      .master("local[2]")
      .config("spark.sql.warehouse.dir", warehouseLocation)
      .enableHiveSupport()
      .getOrCreate()
    //...
    import spark.sql
    sql("CREATE TABLE IF NOT EXISTS src (key INT, value STRING)")
    sql("LOAD DATA LOCAL INPATH 'input/kv1.txt' INTO TABLE src")
    sql("SELECT * FROM src").show()
  }
}
//#-------------------------------------------------
//#Spark 链接mssqlserver
//#-------------------------------------------------
Step 1: 下载sqljdbc_6.0.7728.100_enu.exe，解压
Step 2: 导入文件sqljdbc4.jar到IDEA工程的library
val jdbcDF = spark.read
  .format("jdbc")
  .option("url", "jdbc:sqlserver://localhost:49434;databasename=Landa_CDRJ_153_2_04")
  .option("dbtable", "dbo.CSEMPL_1")
  .option("user", "sa")
  .option("password", "123456")
  .load()
jdbcDF.printSchema()