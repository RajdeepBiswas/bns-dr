#!/bin/bash
#script for daily distcp, to be run from DR cluster

#data parameters
#now=$(date +'%Y-%m-%d')
now=2016-12-04

#PROD and DR Nameservice ID (Namenode Host)
prod=ip-172-40-1-51.ec2.internal
dr=ip-172-40-1-51.ec2.internal

#Prod host that will execute commands 
prod_host=ip-172-40-1-169.ec2.internal
hive_host=ip-172-40-1-115.ec2.internal

function log {
DATE2=$(date +"%Y-%m-%d %T,%s")
if [[ $1 == 0 ]]; then
        echo -e "[$DATE2] INFO - Completed Step: $2" >> /tmp/logs/distcp.log
else
        echo -e "[$DATE2] ERROR - Failed on Step: $2" >> /tmp/logs/distcp.err
        exit 1;
fi
}

daily() {
echo "......Creating snapshot on PROD now starting at "  $(date)
ssh $prod_host "hdfs dfs -createSnapshot hdfs://$prod/ $now"

echo "......Creating mysql dump on PROD"
ssh $hive_host "mysqldump -u root hive > hive_db_backup.sql"

echo "......Scrubbing mysql dump "
#do scrubbing

echo ".....Store scrubeed mysql dump in HDFS"
#store in HDFS
log $? "create snapshot, hive sql dump created, scrubbed and stored in HDFS"

echo "......Distcp snapshot from PROD to DR" 
while read p; do
  hadoop distcp -p -i -strategy dynamic -m 200 -log /tmp/distcp/$now -update -delete hdfs://$prod:8020/.snapshot/$now$p hdfs://$dr:8020$p
done < test_folder_list.txt
log $? "distcp snapshot to DR"

echo "......Creating snapshot on DR" 
hdfs dfs -createSnapshot hdfs://$dr/ $now
log $? "create snapshot in DR"
}

if [ "$1" = "daily" ]
then
    daily
elif [ "$1" = "diff_report" ]
then
    diff_report
else
        echo "Invalid env"
        exit 1;
fi
