###############################################
# This file does the next:
# 1. Saves a backup of actual logs
# 2. Copies updated logs from a remote machine
# 3. Saves a backup of hdfs logs
# 4. Updates the actual hdfs logs
###############################################

# vars
LOG_FILE='/var/log/cronjobs_logs/CP_LOGS_FROM_LMS.log'
HDFS_LOGS_BACKUP='/home/eduardoperez/Backups/hdfs_logs'
TRACKING_PATH="/etc/var/log/tracking"
OLD_LOGS_DIR="/etc/var/log/tracking/old/"
DATE=`date +%Y-%m-%d`
REMOTE_MACHINE=$1

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ CLEAR LOG ]"
echo '' > "$LOG_FILE"
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ GIVE HADOOP USER ACCESS TO LOGS DIR ]"
sudo chown hadoop $TRACKING_PATH
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ CREATE OLD LOGS DIR ]"
if [ ! -d "$OLD_LOGS_DIR" ]; then
	mkdir "$OLD_LOGS_DIR"
fi
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ DELETE COMPRESSED OLD LOGS ]"
rm -fr $TRACKING_PATHold/*
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ COMPRESS & SAVE ACTUAL LOGS ]"
cd "$TRACKING_PATH/"
tar -zcvf OLD_LOGS_"$DATE".tar.gz tracking.log*
mv OLD_LOGS_"$DATE".tar.gz "$OLD_LOGS_DIR"
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ DELETE ACTUAL LOGS ]"
rm -fr $TRACKING_PATH/tracking.log*
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ COPYING LOGS FROM LMS ]"
scp $REMOTE_MACHINE:$TRACKING_PATH/* $TRACKING_PATH
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ UNCOMPRESS NEW LOGS ]"
cd "$TRACKING_PATH"
gunzip *.gz
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ GIVE CORRECT PERMISSIONS TO LOGS ]"
sudo chown -R hadoop:devedx $TRACKING_PATH/tracking.log*
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ CREATE HDFS LOGS BACKUP ]"
mkdir "$HDFS_LOGS_BACKUP"/"$DATE"
/edx/app/hadoop/hadoop/bin/hdfs dfs -get /data/* "$HDFS_LOGS_BACKUP"/"$DATE"
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ REMOVE LOGS FROM HDFS ]"
/edx/app/hadoop/hadoop/bin/hdfs dfs -rm -f -r /data/*
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ UP UPDATED LOGS TO HDFS ]"
/edx/app/hadoop/hadoop/bin/hdfs dfs -put $TRACKING_PATH/tracking.log* /data/
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ TASK FINISHED ]"
echo "TASK FINISHED"
