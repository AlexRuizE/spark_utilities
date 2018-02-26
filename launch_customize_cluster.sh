#!/bin/bash

# This script allows a user to launch their own Spark standalone cluster. 
# It uses Spark's native methods that come by default with every download.
# The first part of the script launches a cluster from the local terminal. 
# The second one customizes the master and slaves with updates and new packages, and must
# be run from the remote terminal (for example in a file called setup.sh).
# Finally, a short sequence of steps to enable persistent hdfs (to persist data across restarts).


##########################
# Launch cluster (local) #
##########################
export AWS_SECRET_ACCESS_KEY=<>  AWS_ACCESS_KEY_ID=<>

# Change dir to Spark's launcher executable
cd /Applications/spark-1.5.2-bin-hadoop2.4/ec2

# Launch cluster (takes time). Active .pem file must be available. <s> defines number of instances.
./spark-ec2 -k spark -i /path/to/pem/file.pem -s 4 --instance-type=m1.xlarge launch DATASCIENCE_CLUSTER


################################################
# Install dependencies and propagate to slaves #
################################################

# Install pssh to parallelize ssh connections to worker nodes
yum -y pssh

# Install pip and python 
yum -y install python34 python34-devel python34-pip
pssh --timeout 0 -h /root/spark-ec2/slaves yum -y install python34 python34-devel python34-pip

pip-3.4 install -U pandas boto requests ipython # scipy scikit-learn 
pssh --timeout 0 -h  /root/spark-ec2/slaves pip-3.4 install -U pandas boto requests #scipy scikit-learn

# Set PYTHONHASHSEED locally
echo "export PYTHONHASHSEED=0" >> /root/.bashrc
source /root/.bashrc

# Set PYTHONHASHSEED on all slaves
pssh -h /root/spark-ec2/slaves 'echo "export PYTHONHASHSEED=0" >> /root/.bashrc'

# Restart all slaves
sh /root/spark/sbin/stop-slaves.sh
sh /root/spark/sbin/start-slaves.sh

# Configs
cp spark/conf/spark-env.sh.template spark/conf/spark-env.sh
echo "export PYTHONHASHSEED=0" >> /root/spark/conf/spark-env.sh
echo "export PYSPARK_PYTHON=/usr/bin/python3.4" >> /root/spark/conf/spark-env.sh
echo "PYSPARK_DRIVER_PYTHON=ipython3" >> /root/spark/conf/spark-env.sh

### END bash FILE




##########################
# Enable persistent-hdfs #
##########################
# 1. edit persistent-hdfs/conf/core-site-xml and add <vol0> (name of persistent volume in master node) under “hadoop.tmp.dir”
# 2. spark-ec2/copy-dir.sh persistent-hdfs/conf/core-site.xml
# 3. spark/sbin/stop-all.sh
# 4. spark/sbin/start-all.sh (restart workers to load changes is core-xml)
# 5. spark/sbin/stop-all.sh
# 6. change persistent-hdfs/conf/core-site-xml back to original value <vol0> —> <vol>
# 7. finally restart workers spark/sbin/start-all.sh
