# 🚀 Target-Ops: dba-tools

Welcome to **dba-tools**,

## 🌟 Features

### MySQL 🐬
The `mysql` directory is your go-to place for MySQL-related automation:

- **backup**: A Dockerized solution for logical backup and restore at scale of MySQL databases. Utilizing:
  - `azcopy`
  - `mysql`
  - `mydumper`
  - `myloader`
  - `percona-toolkit`
  - `Docker`
  - `mysqlkit`
  
  - **mysqlkit.sh**: CLI toolkit for MySQL database backup and restore. The MySQL Toolkit 🚀 supports the following commands:
    - **backup**: Create backups of AWS RDS DB MySQL tables and upload them to a Blob Store.
    - **restore**: Restore MySQL tables from Blob Storage.
    - **test_script**: Test the script and display some diagnostic information.
    - **run_command**: Execute SQL commands or MySQL Client commands.
    - **restore_command**: Execute restore and run_command sequentially.

---

## 📦 Installation


## 🚀 Usage
See each individual tool's README

## 💡 Contributing
We welcome contributions from the community! Feel free to contribute to the repository and submit pull requests.

## Core required for ghpage
https://github.com/jrnewton/github-readme-to-html 
```
npx github-readme-to-html README.md
cp dist/index.html ./README.html && rm -rf ./dist/
```
