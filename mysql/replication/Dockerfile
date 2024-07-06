# Use an official Debian-based  minimal image as a base
FROM debian:stable-slim

# useful tools for the jumpbox pod connecting to DBs for maintenantce

RUN apt-get update && apt-get install -y \
    percona-toolkit \
    postgresql-client \
    default-mysql-client \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    less \
    htop \
    net-tools \
    iproute2 \
    dnsutils \
    procps \
    unzip \
    zip \
    tar \
    sudo \
    make \
    netcat-openbsd \
    traceroute \
    telnet \
    tcpdump \
    nmap \
    lsof \
    strace \
    tmux \
    screen \
    ncdu \
    rsync \
    psmisc \
    iftop \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    docker.io \
    bash

RUN curl -LO https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl && \
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER root
WORKDIR /root
ENV HOSTNAME tools


ENTRYPOINT ["bash"]
