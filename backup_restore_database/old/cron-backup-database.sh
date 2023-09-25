#!/bin/bash
# Declare function
function backup-database() {
		if [ "$1" = "" ]
		then
			echo "Argument missing database name."
			exit 1
		fi

		# (1) set up all the mysqldump variables
		DATE=`date +"%Y-%m-%d-%H%M%S"`
		DATABASE=$1
		SQL_PATH=/var/backups/db/
		SQL_FILE=${SQL_PATH}${DATABASE}_${DATE}.sql
		KEEP_BACKUP_FILE_DAY=30

		# (2) do the mysql database backup (dump)
		if [ ! -d "$SQL_PATH" ]
		then
			mkdir "$SQL_PATH"
		fi

		mysqldump -u iwa -pcpower1234 --opt --routines --events --single-transaction --skip-lock-tables ${DATABASE}|gzip > ${SQL_FILE}.gz
		find ${SQL_PATH}. -mtime +${KEEP_BACKUP_FILE_DAY} -exec rm {} \;
}

# Execute script
backup-database iwa_bms
backup-database iwa_dp
backup-database alert
backup-database iwa_facility_property
