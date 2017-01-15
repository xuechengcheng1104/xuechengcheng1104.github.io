
//**************************************************
//*Spark RDD - basic
//**************************************************
scala> val acTransList = Array("SB10001,1000","SB10002,1200","SB10003,8000","SB10004,400","SB10005,300","SB10006,10000","SB10007,500","SB10008,56","SB10009,30","SB10010,7000","CR10001,7000","SB10002,-10")
scala> val acTransRDD = sc.parallelize(acTransList)
scala> val goodTransRecords = acTransRDD.filter(_.split(",")(1).toDouble > 0).filter(_.split(",")(0).startsWith("SB"))
scala> val highValueTransRecords = goodTransRecords.filter(_.split(",")(1).toDouble>1000)
scala> val badAmountLambda = (trans : String) => trans.split(",")(1).toDouble <= 0
scala> val badAcNoLambda = (trans : String) => trans.split(",")(0).startsWith("SB") == false
scala> val badAmountRecords = acTransRDD.filter(badAmountLambda)
scala> val badAccountRecords = acTransRDD.filter(badAcNoLambda)
scala> val badTransRecords=badAmountRecords.union(badAccountRecords)
scala> acTransRDD.collect()
scala> goodTransRecords.collect()
scala> highValueTransRecords.collect()
scala> badAccountRecords.collect()
scala> badAmountRecords.collect()
scala> badTransRecords.collect()
scala> val sumAmount = goodTransRecords.map(trans => trans.split(",")(1).toDouble).reduce(_+_)
scala> val maxAmount = goodTransRecords.map(trans => trans.split(",")(1).toDouble).reduce((a,b) => if (a>b) a else b)
scala> val minAmount = goodTransRecords.map(trans => trans.split(",")(1).toDouble).reduce((a,b) => if (a<b) a else b)
scala> val combineAllElements = acTransRDD.flatMap(trans=>trans.split(","))
scala> val allGoodAccountNos = combineAllElements.filter(_.startsWith("SB"))
scala> combineAllElements.collect()
scala> allGoodAccountNos.distinct().collect()
//**************************************************
//*Spark RDD - key-value
//**************************************************
scala> val acTransList = Array("SB10001,1000","SB10002,1200","SB10001,8000","SB10002,400","SB10003,300","SB10001,10000","SB10004,500","SB10005,56","SB10003,30","SB10002,7000","SB10001,-100","SB10002,-10")
scala> val acTransRDD = sc.parallelize(acTransList)
scala> val acKeyVal = acTransRDD.map(trans => (trans.split(",")(0), trans.split(",")(1).toDouble))
scala> val accSummary = acKeyVal.reduceByKey(_+_).sortByKey()
scala> accSummary.collect()
//**************************************************
//*Spark RDD - join
//**************************************************
scala> val acMasterList = Array("SB10001,Roger,Federer","SB10002,Pete,Sampras","SB10003,Rafael,Nadal","SB10004,Boris,Becker","SB10005,Ivan,Lendl")
scala> val acBalList = Array("SB10001,50000","SB10002,12000","SB10003,3000","SB10004,8500","SB10005,5000")
scala> val acMasterRDD = sc.parallelize(acMasterList)
scala> val acBalRDD = sc.parallelize(acBalList)
scala> val acMasterTuples = acMasterRDD.map(master => master.split(",")).map(masterList => (masterList(0), masterList(1)+" "+masterList(2)))
scala> val acBalTuples = acBalRDD.map(trans => trans.split(",")).map(transList => (transList(0), transList(1)))
scala> val acJoinTuples = acMasterTuples.join(acBalTuples).sortByKey().map{case(accno, (name, amount)) => (accno, name, amount)}
scala> acJoinTuples.collect()
scala> val acNameAndBalance = acJoinTuples.map{case(accno, name, amount) => (name,amount)}
scala> val acTuplesByAmount = acBalTuples.map{case(accno, amount) => (amount.toDouble, accno)}.sortByKey(false)
scala> acTuplesByAmount.first()
scala> acTuplesByAmount.take(3)
scala> acBalTuples.countByKey()
scala> acBalTuples.count()
scala> acNameAndBalance.foreach(println)
scala> val balanceTotal = sc.accumulator(0.0, "AccountBalanceTotal")
scala> acBalTuples.map{case(accno, amount) => amount.toDouble}.foreach(bal => balanceTotal += bal)
scala> balanceTotal.value
//**************************************************
//*Spark SQL - SQL
//**************************************************
scala> case class Trans(accNo: String, tranAmount: Double)
scala> def toTrans = (trans: Seq[String]) => Trans(trans(0), trans(1).trim.toDouble)
scala> val acTransList = Array("SB10001,1000", "SB10002,1200","SB10003,8000", "SB10004,400", "SB10005,300", "SB10006,10000","SB10007,500", "SB10008,56", "SB10009,30","SB10010,7000", "CR10001,7000","SB10002,-10")
scala> val acTransRDD =sc.parallelize(acTransList).map(_.split(",")).map(toTrans(_))
scala> val acTransDF = spark.createDataFrame(acTransRDD)
scala> acTransDF.createOrReplaceTempView("trans")
scala> acTransDF.printSchema
scala> acTransDF.show
scala> val goodTransRecords = spark.sql("SELECT accNo, tranAmount FROM trans WHERE accNo like 'SB%' AND tranAmount > 0")
scala> goodTransRecords.createOrReplaceTempView("goodtrans")
scala> goodTransRecords.show
scala> val highValueTransRecords = spark.sql("SELECT accNo, tranAmount FROM goodtrans WHERE tranAmount > 1000")
scala> highValueTransRecords.show
scala> val badAccountRecords = spark.sql("SELECT accNo, tranAmount FROM trans WHERE accNo NOT like 'SB%'")
scala> badAccountRecords.show
scala> val badAmountRecords = spark.sql("SELECT accNo, tranAmount FROM trans WHERE tranAmount < 0")
scala> badAmountRecords.show
scala> val badTransRecords = badAccountRecords.union(badAmountRecords)
scala> badTransRecords.show
scala> val sumAmount = spark.sql("SELECT sum(tranAmount) as sum FROM goodtrans")
scala> sumAmount.show
scala> val maxAmount = spark.sql("SELECT max(tranAmount) as max FROM goodtrans")
scala> maxAmount.show
scala> val minAmount = spark.sql("SELECT min(tranAmount) as min FROM goodtrans")
scala> minAmount.show
scala> val goodAccNos = spark.sql("SELECT DISTINCT accNo FROM trans WHERE accNo like 'SB%' ORDER BY accNo")
scala> goodAccNos.show
scala> val sumAmountByMixing = goodTransRecords.map(trans => trans.getAs[Double]("tranAmount")).reduce(_ + _)
scala> val maxAmountByMixing = goodTransRecords.map(trans => trans.getAs[Double]("tranAmount")).reduce((a, b) => if (a > b) a else b)
scala> val minAmountByMixing = goodTransRecords.map(trans => trans.getAs[Double]("tranAmount")).reduce((a, b) => if (a < b) a else b)
//**************************************************
//*Spark SQL - API
//**************************************************
scala> acTransDF.show
scala> val goodTransRecords = acTransDF.filter("accNo like 'SB%'").filter("tranAmount > 0")
scala> goodTransRecords.show
scala> val highValueTransRecords = goodTransRecords.filter("tranAmount > 1000")
scala> highValueTransRecords.show
scala> val badAccountRecords = acTransDF.filter("accNo NOT like 'SB%'")
scala> badAccountRecords.show
scala> val badAmountRecords = acTransDF.filter("tranAmount < 0")
scala> badAmountRecords.show
scala> val badTransRecords = badAccountRecords.union(badAmountRecords)
scala> badTransRecords.show
scala> val aggregates = goodTransRecords.agg(sum("tranAmount"), max("tranAmount"), min("tranAmount"))
scala> aggregates.show
scala> val goodAccNos = acTransDF.filter("accNo like 'SB%'").select("accNo").distinct().orderBy("accNo")
scala> goodAccNos.show
scala> acTransDF.write.parquet("scala.trans.parquet")
scala> val acTransDFfromParquet = spark.read.parquet("scala.trans.parquet")
scala> acTransDFfromParquet.show
//**************************************************
//*Spark SQL - aggreation
//**************************************************
scala> case class Trans(accNo: String, tranAmount: Double)
scala> def toTrans = (trans: Seq[String]) => Trans(trans(0), trans(1).trim.toDouble)
scala> val acTransList = Array("SB10001,1000","SB10002,1200","SB10001,8000", "SB10002,400", "SB10003,300","SB10001,10000","SB10004,500","SB10005,56","SB10003,30","SB10002,7000","SB10001,-100", "SB10002,-10")
scala> val acTransDF = sc.parallelize(acTransList).map(_.split(",")).map(toTrans(_)).toDF()
scala> acTransDF.show
scala> acTransDF.createOrReplaceTempView("trans")
scala> val acSummary = spark.sql("SELECT accNo, sum(tranAmount) as TransTotal FROM trans GROUP BY accNo")
scala> acSummary.show
scala> val acSummaryViaDFAPI = acTransDF.groupBy("accNo").agg(sum("tranAmount") as "TransTotal")
scala> acSummaryViaDFAPI.show
//**************************************************
//*Spark SQL - join
//**************************************************
scala> case class AcMaster(accNo: String, firstName: String, lastName: String)
scala> case class AcBal(accNo: String, balanceAmount: Double)
scala> def toAcMaster = (master: Seq[String]) => AcMaster(master(0), master(1), master(2))
scala> def toAcBal = (bal: Seq[String]) => AcBal(bal(0), bal(1).trim.toDouble)
scala> val acMasterList =Array("SB10001,Roger,Federer","SB10002,Pete,Sampras","SB10003,Rafael,Nadal","SB10004,Boris,Becker", "SB10005,Ivan,Lendl")
scala> val acBalList = Array("SB10001,50000","SB10002,12000","SB10003,3000", "SB10004,8500", "SB10005,5000")
scala> val acMasterDF = sc.parallelize(acMasterList).map(_.split(",")).map(toAcMaster(_)).toDF()
scala> val acBalDF = sc.parallelize(acBalList).map(_.split(",")).map(toAcBal(_)).toDF()
scala> acMasterDF.write.parquet("scala.master.parquet")
scala> acBalDF.write.json("scalaMaster.json")
scala> val acMasterDFFromFile = spark.read.parquet("scala.master.parquet")
scala> acMasterDFFromFile.createOrReplaceTempView("master")
scala> val acBalDFFromFile = spark.read.json("scalaMaster.json")
scala> acBalDFFromFile.createOrReplaceTempView("balance")
scala> acMasterDFFromFile.show
scala> acBalDFFromFile.show
scala> val acDetail = spark.sql("SELECT master.accNo, firstName, lastName, balanceAmount FROM master, balance WHERE master.accNo = balance.accNo ORDER BY balanceAmount DESC")
scala> acDetail.show
scala> val acDetailFromAPI = acMastterDFFromFile.join(acBalDFFromFile, acMasterDFFromFile("accNo") === acBalDFFromFile("accNo"), "inner").sort($"balanceAmount".desc).select(acMasterDFFromFile("accNo"),acMasterDFFromFile("firstName"), acMasterDFFromFile("lastName"),acBalDFFromFile("balanceAmount"))
scala> acDetailFromAPI.show
scala> val acDetailTop3 = spark.sql("SELECT master.accNo, firstName, lastName, balanceAmount FROM master, balance WHERE master.accNo = balance.accNo ORDER BY balanceAmount DESC").limit(3)
scala> acDetailTop3.show
//**************************************************
//*Spark SQL - dataset
//**************************************************
scala> case class Trans(accNo: String, tranAmount: Double)
scala> val acTransList = Seq(Trans("SB10001", 1000), Trans("SB10002",1200),Trans("SB10003", 8000), Trans("SB10004",400), Trans("SB10005",300),Trans("SB10006",10000), Trans("SB10007",500), Trans("SB10008",56),Trans("SB10009",30),Trans("SB10010",7000), Trans("CR10001",7000),Trans("SB10002",-10))
scala> val acTransDS = acTransList.toDS()
scala> acTransDS.show()
scala> val goodTransRecords = acTransDS.filter(_.tranAmount > 0).filter(_.accNo.startsWith("SB"))
scala> goodTransRecords.show()
scala> val highValueTransRecords = goodTransRecords.filter(_.tranAmount > 1000)
scala> highValueTransRecords.show()
scala> val badAmountLambda = (trans: Trans) => trans.tranAmount <= 0
scala> val badAcNoLambda = (trans: Trans) => trans.accNo.startsWith("SB") == false
scala> val badAmountRecords = acTransDS.filter(badAmountLambda)
scala> badAmountRecords.show()
scala> val badAccountRecords = acTransDS.filter(badAcNoLambda)
scala> badAccountRecords.show()
scala> val badTransRecords = badAmountRecords.union(badAccountRecords)
scala> badTransRecords.show()
scala> val sumAmount = goodTransRecords.map(trans => trans.tranAmount).reduce(_ + _)
scala> val maxAmount = goodTransRecords.map(trans => trans.tranAmount).reduce((a, b) => if (a > b) a else b)
scala> val minAmount = goodTransRecords.map(trans => trans.tranAmount).reduce((a, b) => if (a < b) a else b)
scala> val acTransDF = acTransDS.toDF()
scala> acTransDF.show()
scala> acTransDF.createOrReplaceTempView("trans")
scala> val invalidTransactions = spark.sql("SELECT accNo, tranAmount FROM trans WHERE (accNo NOT LIKE 'SB%') OR tranAmount <= 0")
scala> invalidTransactions.show()
scala> val acTransRDD = sc.parallelize(acTransList)
scala> val acTransRDDtoDF = acTransRDD.toDF()
scala> val acTransDFtoDS = acTransRDDtoDF.as[Trans]
scala> acTransDFtoDS.show()
//**************************************************
//*Spark SQL - catalogs
//**************************************************
scala> val catalog = spark.catalog
scala> val dbList = catalog.listDatabases()
scala> dbList.select("name", "description", "locationUri").show()
scala> val tableList = catalog.listTables()
scala> tableList.show()
scala> catalog.dropTempView("trans")
scala> val latestTableList = catalog.listTables()
scala> latestTableList.show()
//**************************************************
//*IDEA spark enviroment setup
//**************************************************
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
//**************************************************
//*SparkContext
//**************************************************
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
//**************************************************
//*数据源
//**************************************************
val data = Array(1, 2, 3, 4, 5)
val distData = sc.parallelize(data)
println(distData.reduce((a, b) => a + b))
//**************************************************
//*RDD输出
//**************************************************
val distFile = sc.textFile("data.txt")
distFile.foreach(println)
distFile.collect().foreach(println) // fetches the entire RDD to a single machine
distFile.take(30).foreach(println)  // then same as SQL limit 30
counts.saveAsTextFile("output.txt")
counts.coalesce(1,true).saveAsTextFile("output.txt")
counts.repartition(1).saveAsTextFile("output.txt") // the same as the statement above
//**************************************************
//*Key-Value Pairs
//**************************************************
val distFile = sc.textFile("data.txt")
val pairs = distFile.map(s => (s.length, 1))
val counts = pairs.reduceByKey((a, b) => a + b) // the same as SQL group by then count()
counts.foreach(println)
//**************************************************
//*leftOuterJoin
//**************************************************
val rdd1 = sc.makeRDD(Array(("A", "1"),("B", "2"),("C", "3")), 2)
val rdd2 = sc.makeRDD(Array(("A", "a"),("C", "c"),("D", "d")), 2)
val rdd3 = sc.makeRDD(Array(("A", "4"),("C", "5"),("D", "6")), 2)
rdd1.leftOuterJoin(rdd2).leftOuterJoin(rdd3).collect.foreach(println)
rdd1.leftOuterJoin(rdd2).leftOuterJoin(rdd3).repartition(1).saveAsTextFile("output/output.txt")
//**************************************************
//*文件源
//**************************************************
val distFile = sc.textFile("data.txt")
println(distFile.map(s => s.length).reduce((a, b) => a + b))
//**************************************************
//*define user function
//**************************************************
val distFile = sc.textFile("data.txt")
val field = "Hello "
def doStuff(rdd: RDD[String]): RDD[String] = { rdd.map(x => field + x) }
doStuff(distFile).foreach(println)
//**************************************************
//*accumulator
//**************************************************
val accum = sc.accumulator(0)
sc.parallelize(Array(1, 2, 3, 4)).foreach(x => accum += x)
println(accum.value)
//**************************************************
//*StreamingContext
//**************************************************
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
//**************************************************
//*Socket数据源
//**************************************************
val lines = ssc.socketTextStream("localhost", 9999)
val words = lines.flatMap(_.split(" "))
val pairs = words.map(word => (word, 1))
val wordCounts = pairs.reduceByKey(_ + _)  // the same as SQL group by then count()
wordCounts.foreachRDD(rdd => rdd.foreach(println))
//**************************************************
//*RDD队列数据源
//**************************************************
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
//**************************************************
//*累计更新键值
//**************************************************
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
//**************************************************
//*SparkContext -> SparkSession
//**************************************************
val rdd1 = sc.makeRDD(Array(("A", "1"),("B", "2"),("C", "3")), 2)
val spark = SparkSession.builder.config(rdd1.sparkContext.getConf).getOrCreate()
import spark.implicits._ //隐式转换
rdd1.toDF("word", "code").createOrReplaceTempView("words") // Register the DataFrame as a SQL temporary view
val wordCountsDataFrame = spark.sql("select * from words")
//**************************************************
//*init SparkSession
//**************************************************
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
//**************************************************
//*读取json文件，输出DF
//**************************************************
val path = "input/data02.txt"
spark.read.json(path).createOrReplaceTempView("Employee")
val EmployeeDF=spark.sql("select * from Employee")
EmployeeDF.printSchema()
EmployeeDF.show()
//**************************************************
//*DF操作
//**************************************************
wordCountsDataFrame.printSchema()
wordCountsDataFrame.show()
wordCountsDataFrame.select("word").show()
wordCountsDataFrame.select($"word", $"code"+10).show()
wordCountsDataFrame.groupBy($"word").count()show()
wordCountsDataFrame.filter($"code" > 4).show()
//**************************************************
//*toDS
//**************************************************
case class Person(name: String, age: Long) //放到main函数外面
import spark.implicits._
val caseClassDS = Seq(Person("Andy", 32)).toDS()
caseClassDS.show()
val primitiveDS = Seq(1, 2, 3).toDS()
primitiveDS.map(_ + 1).show()
//**************************************************
//*toDF
//**************************************************
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
//**************************************************
//*Specifying the Schema
//**************************************************
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
//**************************************************
//*default source format-parquet
//**************************************************
val path = "input/users.parquet"
val usersDF = spark.read.load(path)
usersDF.printSchema()
usersDF.select("name", "favorite_color").show()
usersDF.select("name", "favorite_color").write.save("output/namesAndFavColors.parquet")
//**************************************************
//*manully specify format
//**************************************************
val path = "input/people.json"
val peopleDF = spark.read.format("json").load(path)
peopleDF.printSchema()
peopleDF.show()
peopleDF.select("name", "age").write.format("parquet").save("output/namesAndAges.parquet")
//**************************************************
//*run sql on file
//**************************************************
val sqlDF = spark.sql("SELECT * FROM json.`input/ChineseCities.json`")
sqlDF.printSchema()
sqlDF.select("city.area").show()
sqlDF.select("city.area").write.format("json").save("output/namesAndAges.json")
//**************************************************
//*partition merge
//**************************************************
import spark.implicits._
val squaresDF = spark.sparkContext.makeRDD(1 to 5).map(i => (i, i * i)).toDF("value", "square")
squaresDF.write.parquet("output/data/test_table/key=1")
val cubesDF = spark.sparkContext.makeRDD(6 to 10).map(i => (i, i * i * i)).toDF("value", "cube")
cubesDF.write.parquet("output/data/test_table/key=2")
val mergedDF = spark.read.option("mergeSchema", "true").parquet("output/data/test_table")
mergedDF.printSchema()
mergedDF.show()
//**************************************************
//*RDD存放json数据
//**************************************************
val otherPeopleRDD = spark.sparkContext.makeRDD("""{"name":"Yin","address":{"city":"Columbus","state":"Ohio"}}""" :: Nil)
otherPeopleRDD.foreach(println)
val otherPeople = spark.read.json(otherPeopleRDD)
otherPeople.printSchema()
otherPeople.select("name","address.city","address.state").show()
//**************************************************
//*Spark-Hive SQL
//**************************************************
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
//**************************************************
//*Spark 链接mssqlserver
//**************************************************
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