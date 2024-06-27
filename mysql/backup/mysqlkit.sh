#!/bin/bash

# This script will work only for backup/restore while both DBs running MYSQL.

command=$MBL_COMMAND

#Backup folder to hold db backup folder - needs write p[ermission
bkp_pth="/etc/backup"
# log storage path
log_pth="$bkp_pth/logs"
log_file="${log_pth}/script_${command}_log"
#blob to hold backups
blob=$BLOB_URI
#db host 
host=$DB_HOST
#db user 
user=$DB_USER
#db name 
db="${DATABSE:=innodb}" 
specific_table=()
sql_command=$SQL_COMMAND

allowed_commands=["help","backup","restore","test_script","run_command","s3toblob","restore_command"]

emit(){
	echo "<$(date '+%d/%m/%Y %H:%M:%S')>: ${1}" >> $log_file
}

if [[ -n "${SINGLE_TABLE}" ]]; then
	specific_table[${#specific_table[@]}]=$SINGLE_TABLE
fi

#Tables to ignore while backing up
system_tables=["","",""]

required_software=("azcopy" "wget" "mysql" "mydumper" "myloader")

check_dependencies(){
	emit "Checking ${#required_software[@]} required dependencies..."	
	for var in "${required_software[@]}"
	do
		hash $var 2>/dev/null || { emit >&2 "Required software $var not installed. Aborting."; exit 1; }
	done
}


help(){
	echo "Script to copy AWS RDS to Azure MySQL flexible server"
	echo "Use the following options to configure:"
	echo "-c (command): MANDATORY, can be backup or restore"
	echo "-h (host): MANDATORY, the hostname of the mysql server"
	echo "-u (username): MANDATORY, the username used to connect to the mySQL"
	echo "-d (database): MANDATORY, the database name to backup or restore to"
	echo "-t (threads): number of threads to use, defaults to 16"
}

test_script() {
	emit "--- script test ---"
	emit "Single_table: ${SINGLE_TABLE}"
	emit "specific_table size: ${#specific_table[@]}"
	emit "specific_table content: "${specific_table[*]}""
}

run_command() {
	if [[ -z "${sql_command}" ]]; then
		emit "FAILED: Running in \"run_command\" mode without specifying sql_command... "
		exit 1
	fi

	#emit "Running command: ${sql_command}"
	emit "Running command list... "
	
	readarray -td '|' commands_array <<<"$sql_command|"
	#Unset last element to remove trailing new line
	unset 'commands_array[-1]'

	for i in "${!commands_array[@]}"; do
		emit "Running command: ${commands_array[i]}"
                readarray -td ';' arrIN <<<"${commands_array[i]};"
                unset 'arrIN[-1]'
		if [[ ${arrIN[0]} == "mysql_cli" ]]; then
			command_result==$(mysql -h $host -u $user -se "use $db; ${arrIN[1]};");
		else		
			command_result==$(pt-online-schema-change --alter "${arrIN[1]}" D=$db,t=${arrIN[0]} --host $host --user $user --password $MYSQL_PWD --execute);
		fi
		emit "Command result: ${command_result}"
	done
}

backup(){
	stop_replication_result=$(mysql -h $host -u $user -se "CALL mysql.rds_stop_replication;")
	emit $stop_replication_result

	if (( ${#specific_table[@]} == 1 )); then
		table_array=("${specific_table[@]}")
	else
		#Fetch all existing tables from db
		existing_tables=$(mysql -h $host -u $user -se "use $db; SHOW TABLES;")
		
		#Convert delimeter to ,
		mod_delim_tables=$(echo $existing_tables | sed -e 's/\s\+/,/g')

		#convert to array
		readarray -td, table_array <<<"$mod_delim_tables,"
		#Unset last element to remove trailing new line
		unset 'table_array[-1]'

		#remove system tables that start with "_" and in system_tables array
		for i in "${!table_array[@]}"; do
			#table_array[$i]=${table_array[i]%,*} 
			if [[ ${table_array[i]} == "test_table" || $system_tables =~ ${table_array[i]} ]]; then
				emit "Unsetting: ${table_array[i]}"
				unset 'table_array[i]'
			fi
		done
	fi

	#Backup and upload all tables 
	for i in "${!table_array[@]}"; do
		current_table=${table_array[i]}
		
		emit "Backing up table ${current_table}"
		mydumper --host=$host --user=$user --password=$MYSQL_PWD --outputdir=${bkp_pth}/${current_table}_backup --rows=100000000 --compress --build-empty-files --threads=16 --compress-protocol --trx-consistency-only --ssl  --regex "^($db\.$current_table)$" -L ${log_pth}/${current_table}-mydumper-logs.log

		emit "Copying backup of ${current_table} to blob storage..."
		azcopy copy ${bkp_pth}/${current_table}_backup ${blob}${BLOB_SAS_TOKEN} --recursive

		emit "Transfer complete, deleting local copy of ${current_table}."
		rm -r ${bkp_pth}/${current_table}_backup
	done
}

restore(){
	if (( ${#specific_table[@]} == 1 )); then
		table_array=("${specific_table[@]}")
	else
		#Fetch list of tables from blob storage
		tables=$(azcopy ls "${blob}${BLOB_SAS_TOKEN}" | cut -d/ -f 1 | awk '!a[$0]++' | cut -d' ' -f 2 | sed -e 's/_backup/,/g')
		
		#Convert list to array
		tables=$(echo $tables | sed -e 's/\s*//g')
		readarray -td, table_array <<<"$tables"
		#Unset last element to remove trailing new line
		unset 'table_array[-1]'
	fi

	#Loop over table, copy locally and load to mysql
	for i in "${!table_array[@]}"; do
		current_table=${table_array[i]}
		emit "Copying talbe ${current_table}"
		emit "copy parameters: ${blob}/${current_table}_backup ${bkp_pth} --recursive"
		azcopy copy "${blob}/${current_table}_backup${BLOB_SAS_TOKEN}" ${bkp_pth} --recursive
		
		#Load table to mysql
		emit "Starting import of table ${current_table}"
		myloader --host=$host --user=$user --password=$MYSQL_PWD --directory=${bkp_pth}/${current_table}_backup --queries-per-transaction=100000 --threads=16 --compress-protocol --ssl --verbose=2 --innodb-optimize-keys -e 2>${log_pth}/${current_table}-myloader-logs-restore.log

		#Remove local copy
		emit "Transfer complete, deleting local copy of ${current_table}"
		rm -r ${bkp_pth}/${current_table}_backup
	done
}

restore_command(){
	restore
	run_command
}

if [ $# == 0 ] && [ $command == "" ]
then
	help
else
	while getopts c:h:u:d: option
	do 
		case "${option}"
			in
			c)command=${OPTARG};;
			h)host=${OPTARG};;
			u)user=${OPTARG};;
			d)db=${OPTARG};;
		esac
	done
	if [[ -z $host || -z $user || -z $db ]]; then
		emit 'one or more variables are undefined'
		exit 1
	fi
	if [[ -z "${MYSQL_PWD}" || -z "${BLOB_SAS_TOKEN}" ]]; then
		emit "Missing password to db OR blob SAS token in env variables: MYSQL_PWD/BLOB_SAS_TOKEN: ${MYSQL_PWD}, ${BLOB_SAS_TOKEN}. Exiting..."
		exit 1
	fi
	check_dependencies
	
	#Create logs folder if does not exist
	if [ ! -d $log_pth ]; then
		  mkdir -p $log_pth;
	fi
	
	emit ""
	emit "--- Script initiated with parameters ---"
	emit "Parameters: ${host} ${user} ${db} ${command}"
	if [[ $allowed_commands =~ $command ]]; 
	then 
		emit "Starting script with command: ${command}"
		$command
		emit "End script with command: ${command}"
	else
		emit "Invalid argument: $command"
		emit "run with \"help\" for possible arguments"
	fi
fi
