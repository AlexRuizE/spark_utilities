# Spark Utilities

Short classes and functions to perform assorted Spark actions. Contains the following scripts:

* **spark_obtain_schema.py**: Class to obtain a full schema of a distributed database stored in *json* format. Useful in conjunction with utilities that allow users to subset distributed dataframes using a known schema to avoid loading data that is not desired.

* **subset_schema.py**: Allows a user to import a small subset of a parquet file from S3. If needed, full schema can be obtained with *spark_obtain_schema.py*.

* **launch_customize_cluster.sh**: This bash script allows a user to launch their own Spark standalone cluster. It uses Spark's (<2.0) native methods that come by default with every standard download. The first part of the script launches a cluster from the local terminal. The second one customizes the master and slaves with updates and new packages, and must be run from the remote terminal (for example in a file called *setup.sh*). Finally, it shows a short sequence of steps to enable persistent *hdfs* (to persist data across restarts) in AWS EC2 instances.

