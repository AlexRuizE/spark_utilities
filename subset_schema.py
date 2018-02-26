"""This script allows a user to import a small subset of a parquet file from S3. 
It is useful to import data efficiently from server logs or data collection systems 
that generate dynamic (or massive) schemas (to avoid loading the entire dataset)."""

from pyspark.sql.types import StructType, StructField, ArrayType, MapType, StringType
from pyspark import SparkContext
from pyspark.sql import SQLContext

# Initialize spark context (pre-Spark 2.0)
sc = SparkContext()
spark = SQLContext(sc)

# Credentials
sc._jsc.hadoopConfiguration().set("fs.s3n.awsAccessKeyId","your_key")
sc._jsc.hadoopConfiguration().set("fs.s3n.awsSecretAccessKey", "your_secret")


# Define desired schema here. Each desired field to be retrieved requires its own line.
# The structure of the each element in schema is: StructField(var_name, var_type, nullable).
# If array, use valueType=ArrayType(DataType())).
schema = StructType([
					StructField("Date", StringType(), nullable=True),
					StructField("Params", MapType(keyType=StringType(), valueType=ArrayType(StringType())), nullable=True),
					StructField("Cookies", MapType(keyType=StringType(), valueType=MapType(keyType=StringType(), valueType=StringType())), nullable=True)
					])


# Set desired path to S3 bucket.
s3path = 's3n://path/to/parquet/dir/*/*/*'
name_of_file = "file_name"+".parquet"

# Initialize and register as SQL table.
df = spark.read.schema(schema).json(s3path)
df.registerTempTable('df')

# Extract, transform and save subset locally as parquet file.
SQL_QUERY = 'select  Date as timestamp, Params.sub_param[0] as sub_param, \
			Params.url[0] as url, Params.referrer[0] as referrer, \
			Cookies.cookie_name.value as cookie from df'
LOCAL_PATH = 'path/to/local/dir/'
FILE_NAME = 'file_name'

spark.sql(SQL_QUERY).write.save(LOCAL_PATH+FILE_NAME, format="parquet")