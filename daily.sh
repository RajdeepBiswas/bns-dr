#!/bin/bash
#script for daily distcp, to be run from DR cluster
#Export variables
. ./conf/conf_daily.sh

function log {
DATE2=$(date +"%Y-%m-%d %T,%s")
if [[ $1 == 0 ]]; then
        echo -e "[$DATE2] INFO - $2" | tee -a /tmp/logs/$distcp_log
else
        echo -e "[$DATE2] ERROR - Failed on Step: $2" | tee -a  /tmp/logs/$distcp_err
        exit 1;
fi
}

daily() {
log $? "......Creating snapshot on PROD now starting at "  $(date)
ssh $prod_host "hdfs dfs -createSnapshot hdfs://$prod/ $now"

log $? "......Creating mysql dump on PROD"
ssh $hive_host "mysqldump -u root hive > hive_db_backup.sql"

log $? "......Scrubbing mysql dump "
#do scrubbing

log $? ".....Store scrubeed mysql dump in HDFS"
#store in HDFS
log $? "Completed Step: create snapshot, hive sql dump created, scrubbed and stored in HDFS"

log $? "......Distcp snapshot from PROD to DR" 
while read p; do
  hadoop distcp -p -i -strategy dynamic -m 200 -log /tmp/distcp/$now -update -delete hdfs://$prod:8020/.snapshot/$now$p hdfs://$dr:8020$p
done < test_folder_list.txt
log $? "Completed Step: distcp snapshot to DR"

log $? "......Creating snapshot on DR" 
hdfs dfs -createSnapshot hdfs://$dr/ $now
log $? "Completed Step: create snapshot in DR at $(date)"
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
