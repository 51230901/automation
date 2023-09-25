#!/bin/bash
# Declare function

function db_list_check() {
	mysql_user="iwa"
	mysql_password="cpower1234"
	desired_dbs=("alert" "iwa_bms" "iwa_dp" "iwa_facility_property")
	db_list=$(mysql -u "$mysql_user" -p"$mysql_password" -e "SHOW DATABASES;" | grep -vE "(Database|information_schema|performance_schema|mysql)")
	# echo "$db_list"

	for desired_db in "${desired_dbs[@]}"; do
		if [[ $db_list == *"$desired_db"* ]]; then
			# echo "$desired_db is exists"
			backup_database "$desired_db" vm-$1 $2 $3	
			put_sftp "$desired_db" vm-$1 $2 $3	
		fi
	done
}

function backup_database() {
	if [ "$1" = "" ]; then
		echo "Argument missing database name."
		exit 1
	fi

	# (1) set up all the mysqldump variables
	# DATE=`date +"%Y-%m-%d-%H%M%S"`
	DATABASE=$1
	VM=$2
	TIMESTAMP=$3
	DEVICE_NAME=$4
	SQL_PATH=/var/backups/db/
	# SQL_FILE=${SQL_PATH}${DATABASE}_${DATE}.sql
	SQL_FILE=${SQL_PATH}${DEVICE_NAME}_${VM}_${DATABASE}_${TIMESTAMP}.sql # /var/backups/db/s235_vm-0_iwa_dp_20230923_153500.sql
	KEEP_BACKUP_FILE_DAY=30

	# (2) do the mysql database backup (dump)
	if [ ! -d "$SQL_PATH" ]; then
		mkdir "$SQL_PATH"
	fi

	mysqldump -u iwa -pcpower1234 --opt --routines --events --single-transaction --skip-lock-tables ${DATABASE} > ${SQL_FILE}
	mysqldump -u iwa -pcpower1234 --opt --routines --events --single-transaction --skip-lock-tables ${DATABASE}|gzip > ${SQL_FILE}.gz
	find ${SQL_PATH}. -mtime +${KEEP_BACKUP_FILE_DAY} -exec rm {} \;
}

function put_sftp() {
	DATABASE=$1
	VM=$2
	TIMESTAMP=$3
	DEVICE_NAME=$4
	target_path="/var/backups/db/"
	SQL_FILE=${DEVICE_NAME}_${VM}_${DATABASE}_${TIMESTAMP}.sql # s235_vm-0_iwa_dp_20230923_153500.sql
	for file in $target_path$SQL_FILE; do
		if [ -e "$file" ]; then
			echo "$file"
			put_sftp="bash <(curl -s http://172.22.0.172:5555/ops/sftp) u ${file} ./import-data/${DEVICE_NAME}"
			echo $put_sftp
			eval "$put_sftp"
			# echo $"eval \"rm -rf $target_path${DEVICE_NAME}_${VM}_${DATABASE}_${TIMESTAMP}.sql\""
			eval "sudo rm -rf $target_path${DEVICE_NAME}_${VM}_${DATABASE}_${TIMESTAMP}.sql"
		else
			echo "The SQL data is NOT exists."
			exit 1
		fi
	done
}

db_list_check $1 $2 $3
