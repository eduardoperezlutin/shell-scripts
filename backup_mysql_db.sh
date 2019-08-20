##############################################################################################
# This script makes a dump backup of a selected database saving it to the OldDatabases Folder.
#
# Arguments:
#
#   db_name
#
##############################################################################################

# vars
TODAY=`date +%Y-%m-%d`

# File where execution log will be saved when executed from cronjob
LOG_FILE='/var/log/cronjobs_logs/BackupReportsUpdated.log'
BACKUP_PATH="/home/eduardoperez/Backups/DB/$TODAY"

if [ $1 == "" ] ; then
	echo "$(date '+%d/%m/%Y %H:%M:%S') ERROR [ DB_NAME MUST BE PROVIDED ]"
	exit 1
fi

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ CLEAR LOG ]"
echo '' > "$LOG_FILE"
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ CREATE TODAY BACKUP DIR ]"
if [ ! -d "$BACKUP_PATH" ]; then
        mkdir "$BACKUP_PATH"
fi
echo "--------------------------------------------------------------------"

echo "$(date '+%d/%m/%Y %H:%M:%S') INFO [ DUMP $1 DATABASE ]"
mysqldump -u root $1 > "$BACKUP_PATH/$1_$TODAY.sql"
echo "--------------------------------------------------------------------"

echo "DONE"