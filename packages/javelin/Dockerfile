FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root

# System deps + X11 test apps
RUN apt update && apt install -y \
    gfortran \
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    python2.7 \
    python-pip \
    python-tk \
    x11-apps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Python deps
RUN pip install --no-cache-dir numpy scipy matplotlib

# Javelin sources
COPY javelin-0.33.tar.gz /root/
RUN tar -xvzf /root/javelin-0.33.tar.gz && rm /root/javelin-0.33.tar.gz

# Build/install Javelin (as you did manually)
WORKDIR /root/javelin-0.33
RUN python setup.py config_fc --fcompiler=gnu95 install

# Default shell
WORKDIR /root
CMD ["bash"]