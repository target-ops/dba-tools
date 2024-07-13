#!/bin/bash 
# This script is used to replicate a master RDS mysql to a replica. See example and usage as echoed below.
# This script replicates a database using the provided environment file as an argument:
#    The environment file should contain the following variables:
#    
#    SRC_HOST: Hostname of the source RDS instance.
#    SRC_USER: Username for the source RDS instance.
#    SRC_PWD: Password for the source RDS instance.
#    DST_HOST: Hostname of the destination RDS instance.
#    DST_USER: Username for the destination RDS instance.
#    DST_PWD: Password for the destination RDS instance.
#    SRC_SLV_USER: Username for the source RDS instance with replication privileges.
#    SRC_SLV_PWD: Password for the source RDS instance user with replication privileges.
# example: ./replicate.sh /path/to/envfile.env mysql-bin.000001 107
set -e

# Check if the correct number of arguments are passed; if not, print usage
if [ "$#" -ne 3 ]; then
  usage
  exit 1
fi

envfile=$1
source $envfile

# This variable stores the current name of the binlog file on source.
FILE_NAME=$2
#binglog position index
POSITION=$3

# Set the MySQL commands for the source and destination RDS instances
MYSQL_SRC_ADMIN="mysql -h$SRC_HOST -u$SRC_USER -p$SRC_PWD"
MYSQL_DST_ADMIN="mysql -h$DST_HOST -u$DST_USER -p$DST_PWD"
MYSQL_SRC_SLAVE="mysql -h$SRC_HOST -u$SRC_SLV_USER -p$SRC_SLV_PWD"

# Set the database name, file name, and position for replication
DB_NAME=app

# Create the replication user on the source RDS instance if it doesn't already exist
# Grant replication slave privileges to the replication user
set +e
$MYSQL_SRC_ADMIN << EOF
CREATE USER '$SRC_SLV_USER'@'%' IDENTIFIED BY '$SRC_SLV_PWD';
GRANT REPLICATION SLAVE ON *.* TO '$SRC_SLV_USER'@'%';
EOF
set -e

# Check if the replication user exists on the source RDS instance
$MYSQL_SRC_SLAVE -e ""

# Verify that the server ids are different between the source and destination RDS instances
SRC_ID=$(echo "show variables like 'server_id'\\G" | $MYSQL_SRC_ADMIN -sN | tail -1)
DST_ID=$(echo "show variables like 'server_id'\\G" | $MYSQL_DST_ADMIN -sN | tail -1)
if [ $SRC_ID = $DST_ID ]; then
    echo ERROR: IDs are identical
    exit 1
fi

# Set the command to set the external master for replication
COMMAND="CALL mysql.rds_set_external_master('$SRC_HOST', 3306, '$SRC_SLV_USER', '$SRC_SLV_PWD', '$FILE_NAME', $POSITION, 0)"

echo $COMMAND

# Start replication on the destination RDS instance
$MYSQL_DST_ADMIN -e "$COMMAND"
$MYSQL_DST_ADMIN -e "CALL mysql.rds_start_replication"
$MYSQL_DST_ADMIN -e "show slave status\G"


usage() {
  echo "Usage: replicate.sh <env_file_path> <binlog_file_name> <binlog_position>"
  echo "  env_file_path: Path to the environment file containing database credentials."
  echo "  binlog_file_name: The current name of the binlog file on the source database."
  echo "  binlog_position: The position within the binlog file to start replication from."
  echo
  echo "Example: ./replicate.sh /path/to/envfile.env mysql-bin.000001 107"
}