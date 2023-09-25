#!/bin/bash

function db_list_check() {
	mysql_user="iwa"
	mysql_password="cpower1234"
	desired_dbs=("alert" "iwa_bms" "iwa_dp" "iwa_facility_property")
	db_list=$(mysql -u "$mysql_user" -p"$mysql_password" -e "SHOW DATABASES;" | grep -vE "(Database|information_schema|performance_schema|mysql)")
	# echo "$db_list"

	for desired_db in "${desired_dbs[@]}"; do
		if [[ $db_list == *"$desired_db"* ]]; then
			# echo "$desired_db is exists"
			restore_database $desired_db
		fi
		rm -rf s235_vm-7_$desired_db.sql
	done
}

function restore_database() {
	SCRIPT_NAME=s235_vm-7_$1.sql
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

db_list_check
