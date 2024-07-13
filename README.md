# 🚀 Target-Ops: dba-tools

Welcome to **dba-tools**,


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

- ** 🌟 Replication Tools 🌟**
  Useful Dockerfile:
    - **Database Tools**: PostgreSQL, MySQL clients, and Percona Toolkit for   MySQL database management.
    - **Networking Tools**: `net-tools`, `iproute2`, `dnsutils`, `traceroute`,    `telnet`, `tcpdump`, `nmap`, etc., for network analysis.
    - **System Monitoring**: `htop`, `iftop`, `ncdu`, `psmisc` for monitoring     system resources.
    - **Miscellaneous Utilities**: `curl`, `wget`, `jq`, `less`, `unzip`,   `zip`,  `tar`, `sudo`, etc., for various tasks.


### AWS RDS 🗄️
  - ** 🔄 replicate.sh 🔄

    This script (`replicate.sh`) automates the process of replicating a master RDS MySQL database to a    replica, ensuring data synchronization across database instances. 🗄️➡️🗄️


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
