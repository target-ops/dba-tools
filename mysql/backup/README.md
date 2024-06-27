# Usage 🚀

The MySQL Toolkit Script supports the following commands:

    help: Display the script's usage and available options.
    backup: Create backups of AWS RDS DB MySQL tables and upload them to a Blob Store.
    restore: Restore MySQL tables from Blob Storage.
    test_script: Test the script and display some diagnostic information.
    run_command: Execute SQL commands or MySQL Client commands.
    restore_command: Execute restore and run_command sequentially.

## Examples 📋

### Backup Command

To create backups of your MySQL tables, use the following command:

```
./mysqlkit.sh -c backup -h your_db_host -u your_db_user -d your_db_name
```
    -c backup: Specifies the backup command.
    -h your_db_host: Replace with your MySQL database host.
    -u your_db_user: Replace with your MySQL database username.
    -d your_db_name: Replace with your MySQL database name.

### Restore Command

To restore MySQL tables from Azure Blob Storage, use the following command:

```

./mysqlkit.sh -c restore -h your_db_host -u your_db_user -d your_db_name
```
    -c restore: Specifies the restore command.
    -h your_db_host: Replace with your MySQL database host.
    -u your_db_user: Replace with your MySQL database username.
    -d your_db_name: Replace with your MySQL database name.

### Test Script

To test the script and see some diagnostic information, use the following command:

```

./mysqlkit.sh -c test_script
```
This command will display information about the script's configuration.
Run Custom SQL Commands

You can run custom SQL commands or MySQL client commands using the run_command command. For example:

```

./mysqlkit.sh -c run_command -d your_db_name -u your_db_user -h your_db_host --sql_command "mysql_cli;SELECT * FROM your_table;mysql_cli;UPDATE your_table SET column='value';"
```
    -c run_command: Specifies the run_command command.
    -d your_db_name: Replace with your MySQL database name.
    -u your_db_user: Replace with your MySQL database username.
    -h your_db_host: Replace with your MySQL database host.
    --sql_command: Specify a list of SQL commands separated by a semicolon (;).

### Restore and Run Custom SQL Commands

To restore tables and then run custom SQL commands, use the following command:

```

./mysqlkit.sh -c restore_command -d your_db_name -u your_db_user -h your_db_host --sql_command "mysql_cli;SELECT * FROM your_table;mysql_cli;UPDATE your_table SET column='value';"
```
This command will restore tables from Blob Storage and then execute the specified SQL commands.

## TODO:

- Add restore from S3 command