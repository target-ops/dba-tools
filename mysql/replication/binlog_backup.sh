#!/bin/bash

# Expects at $1 arg the path to a config file

# This script performs a live backup of MySQL binary logs.
# It expects a single argument: the path to a configuration file.
# The configuration file must define the following variables:
# - BACKUPDIR: The directory where backups will be stored.
# - STARTFILE: The starting binlog file name, used if the backup directory is empty.
# - MYSQLHOST: The MySQL server host.
# - MYSQLPORT: The MySQL server port.
# - MYSQLUSER: The MySQL user for authentication.
# - MYSQLPASS: The password for the MySQL user.
# - RESPAWN: Initial sleep time in seconds before retrying the backup in case of failure, with exponential backoff.
#
# Usage:
# ./binlog_backup.sh <path_to_config_file>
#
# The script enters an infinite loop, continuously backing up the binary logs.
# If the backup directory is empty, it starts with the binlog file specified by STARTFILE.
# Otherwise, it repeats the backup of the last binlog file and continues from there.
# In case of mysqlbinlog tool failure, it retries the connection with exponential backoff, doubling the sleep time after each attempt.
source $1
echo $1
cd $BACKUPDIR

echo "Backup dir: $BACKUPDIR "

while :
do
LASTFILE=$(ls -1 -X $BACKUPDIR | tail -1)
num_files=$(ls $BACKUPDIR | wc -l)

if [ $num_files -eq 0 ]; then
    echo "Starting from binlog file $STARTFILE"
	LASTFILE=$STARTFILE
else
	echo "Repeating back up of last binlog file $LASTFILE to continue"
	echo "rm $BACKUPDIR/$LASTFILE"
        rm -f $BACKUPDIR/$LASTFILE
fi
echo "Starting live binlog backup command:"
echo "MBL --raw --read-from-remote-server --stop-never --host $MYSQLHOST --port $MYSQLPORT -u $MYSQLUSER -pMYSQLPASS $LASTFILE"
$MBL --raw --read-from-remote-server --stop-never --host $MYSQLHOST --port $MYSQLPORT -u $MYSQLUSER -p$MYSQLPASS $LASTFILE

echo "mysqlbinlog exited with $? trying to reconnect in $RESPAWN seconds, expo backoff."

sleep $RESPAWN
(( RESPAWN*=2 ))
done