##Export the variable required for the disctp job

##Snapshot date
now=$(date +'%Y-%m-%d')

#PROD and DR Nameservice ID (Namenode Host)
prod=ip-172-40-1-51.ec2.internal
dr=ip-172-40-1-51.ec2.internal

#Prod host that will execute commands 
prod_host=ip-172-40-1-169.ec2.internal
hive_host=ip-172-40-1-115.ec2.internal

#Daily logs
##Multiple runs will be appended
distcp_log=distcp_$(date +"%Y-%m-%d").log
distcp_err=distcp_$(date +"%Y-%m-%d").err
