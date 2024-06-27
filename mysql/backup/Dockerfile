FROM ubuntu:20.04
LABEL version="0.1"
LABEL description="Docker file to run mydumper/myloader"

ENV TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src/MDL

#Base packages
RUN apt update
RUN apt-get -y install libglib2.0-dev zlib1g-dev libpcre3-dev libssl-dev libzstd-dev wget libatomic1 lsb-release gnupg2  less 

#MyDumper/MyLoader
RUN wget https://github.com/mydumper/mydumper/releases/download/v0.12.3-3/mydumper_0.12.3-3-zstd.focal_amd64.deb
RUN dpkg -i mydumper_0.12.3-3-zstd.focal_amd64.deb

#AZCopy
RUN wget https://aka.ms/downloadazcopy-v10-linux
RUN tar -xvf downloadazcopy-v10-linux
RUN mv ./azcopy_linux_amd64_*/azcopy /usr/bin/

#MySQL library
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb
RUN dpkg -i mysql-apt-config_0.8.22-1_all.deb
RUN apt update
RUN apt install -y mysql-community-client mysql-common

#Install Percona toolkit
RUN apt-get -y install percona-toolkit

#Remove tangling resources
RUN rm -r azcopy_linux_amd*
RUN rm downloadazcopy*
RUN rm mydumper_*.deb

RUN mkdir -p /etc/backup

COPY mysqlkit.sh ./
CMD ["/usr/src/MDL/mysqlkit.sh"]

