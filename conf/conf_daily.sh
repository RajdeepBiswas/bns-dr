##Export the variable required for the disctp job

##Snapshot date
now=$(date +'%Y-%m-%d')

#PROD and DR Nameservice ID (Namenode Host)
prod=ip-1-1-1-1.ec2.internal
dr=ip-172-1-1-1.ec2.internal

#Prod host that will execute commands 
prod_host=ip-1-1-1-1.ec2.internal
hive_host=ip-172-1-1-1.ec2.internal

#Daily logs
##Multiple runs will be appended
distcp_log=distcp_$(date +"%Y-%m-%d").log
distcp_err=distcp_$(date +"%Y-%m-%d").err
