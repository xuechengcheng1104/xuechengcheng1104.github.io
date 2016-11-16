
//##################################################
//#IDEA spark enviroment setup
//##################################################
jdk 1.7
scala 2.10
spark 1.4
//##################################################
//#init SparkContext
//##################################################
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}
object scala {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("Simple Application").setMaster("local")
    val sc = new SparkContext(conf)
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