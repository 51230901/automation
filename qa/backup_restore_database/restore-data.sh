#!/bin/bash

function db_list_check() {
	VM_ID=$1
	TIMESTAMP=$2
	DEVICE_NAME=$3
	mysql_user="iwa"
	mysql_password="cpower1234"
	desired_dbs=("alert" "iwa_bms" "iwa_dp" "iwa_facility_property")
	db_list=$(mysql -u "$mysql_user" -p"$mysql_password" -e "SHOW DATABASES;" | grep -vE "(Database|information_schema|performance_schema|mysql)")
	echo "$db_list"

	for desired_db in "${desired_dbs[@]}"; do
		if [[ $db_list == *"$desired_db"* ]]; then
			echo "$desired_db is exists"
			restore_database $desired_db $1 $2 $3
		else
			echo "$desired_db is NOT exists"
		fi
		eval "sudo rm -rf ${DEVICE_NAME}_vm-${VM_ID}_${desired_db}_${TIMESTAMP}.sql" # s235_vm-0_iwa_dp_20230923_153500.sql
		echo "sudo rm -rf ${DEVICE_NAME}_vm-${VM_ID}_${desired_db}_${TIMESTAMP}.sql"
	done
}

function restore_database() {
	desired_db=$1
	VM_ID=$2
	TIMESTAMP=$3
	DEVICE_NAME=$4
	SCRIPT_NAME=${DEVICE_NAME}_vm-${VM_ID}_${desired_db}_${TIMESTAMP}.sql # s235_vm-0_iwa_dp_20230923_153500.sql
	echo $SCRIPT_NAME

	## Download test-data from SFTP
	bash <(curl -s http://172.22.0.172:5555/ops/sftp) d import-data/s235/$SCRIPT_NAME

	## Drop Database And Create Empty Database
	mysql -u root -pcpower1234 << EOF
	system echo 'Drop Database ';
	drop database $1;
	system echo 'Create Database ';
	create database $1;

	## Restore Database
	system echo 'Restore Database ' ;
	use $1;
	set global log_bin_trust_function_creators=1;
	source $SCRIPT_NAME;
EOF
}

db_list_check $1 $2 $3
