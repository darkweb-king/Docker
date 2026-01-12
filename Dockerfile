# Use Ubuntu as the base image for a familiar Linux environment
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    vim \
    python3 \
    python3-pip \
    nodejs \
    npm \
    build-essential \
    cmake \
    libjson-c-dev \
    libwebsockets-dev \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd (Web-based terminal)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then TTYD_ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then TTYD_ARCH="aarch64"; \
    else TTYD_ARCH="x86_64"; fi && \
    curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH} -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

# Set the working directory
WORKDIR /root

# Create a welcome message that appears when the terminal starts
RUN echo 'echo "========================================"\n\
echo "      Web Terminal Ready to Use         "\n\
echo "========================================"' >> /root/.bashrc

# Render uses a dynamic PORT environment variable.
# We add credentials 'root:root' as requested.
RUN echo '#!/bin/sh\n\
ttyd -p ${PORT:-7681} -c root:root -W bash' > /usr/local/bin/start-terminal.sh && \
    chmod +x /usr/local/bin/start-terminal.sh

# Expose the default port
EXPOSE 7681

# Use tini as an init process
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start the terminal
CMD ["/usr/local/bin/start-terminal.sh"]
