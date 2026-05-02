FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update system
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    vim \
    nano \
    git \
    gcc \
    make \
    python3 \
    python3-pip \
    perl \
    nodejs \
    npm \
    postgresql \
    mysql-server \
    apache2 \
    php \
    php-mysql \
    net-tools \
    netcat-openbsd \
    telnet \
    bind9-utils \
    dnsutils \
    ldap-utils \
    rsync \
    smbclient \
    nmap \
    strace \
    ltrace \
    gdb \
    valgrind \
    jq \
    sqlmap \
    && rm -rf /var/lib/apt/lists/*

# Create SSH directory
RUN mkdir -p /var/run/sshd

# Setup SSH
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config && \
    echo "X11Forwarding yes" >> /etc/ssh/sshd_config && \
    echo "PrintMotd no" >> /etc/ssh/sshd_config && \
    echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config && \
    echo "ListenAddress ::" >> /etc/ssh/sshd_config

# Copy setup scripts
COPY setup-lab.sh /setup-lab.sh
COPY stage1-setup.sh /stage1-setup.sh
COPY vulnerable-service.py /vulnerable-service.py
COPY suid-binary.c /suid-binary.c

RUN chmod +x /setup-lab.sh /stage1-setup.sh

# Run setup
RUN /setup-lab.sh

# Expose SSH
EXPOSE 22

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D"]
