# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary tools, networking utilities, and SSH server
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    vim \
    nano \
    python3 \
    python3-pip \
    nodejs \
    npm \
    build-essential \
    cmake \
    libjson-c-dev \
    libwebsockets-dev \
    tini \
    net-tools \
    iproute2 \
    iputils-ping \
    openssh-server \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH for root access (Username: root, Password: root)
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/session    required     pam_loginuid.so/session    optional     pam_loginuid.so/g' /etc/pam.d/sshd

# Install ttyd (Web-based terminal)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then TTYD_ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then TTYD_ARCH="aarch64"; \
    else TTYD_ARCH="x86_64"; fi && \
    curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH} -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

# Set the working directory
WORKDIR /root

# Create the requested welcome message
RUN echo 'echo "========================================"\n\
echo "      The Abhi terminal Redy            "\n\
echo "========================================"\n\
echo "Networking: Use '\''ifconfig'\'' to see IP"\n\
echo "Shortcuts: Ctrl+C, Ctrl+X, Ctrl+S are enabled."' >> /root/.bashrc

# Create a startup script
# Web login is REMOVED for direct access
RUN echo '#!/bin/sh\n\
# Start SSH server\n\
/usr/sbin/sshd\n\
\n\
# Start ttyd without password\n\
# -W allows writing to the terminal\n\
# -t enableZmodem=true for file transfers\n\
# -t fontSize=14 for readability\n\
ttyd -p ${PORT:-7681} -t enableZmodem=true -t fontSize=14 -W bash' > /usr/local/bin/start-terminal.sh && \
    chmod +x /usr/local/bin/start-terminal.sh

# Expose ports
EXPOSE 22 7681

# Use tini as an init process
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start the services
CMD ["/usr/local/bin/start-terminal.sh"]
