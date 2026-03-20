## What is JAVELIN?

Project repository: https://github.com/nye17/javelin

> JAVELIN stands (reluctantly) for Just Another Vehicle for Estimating Lags In Nuclei. As a version of our SPEAR algorithm written in Python to provide more flexibility in both functionality and visualization. You can use JAVELIN to model quasar variability using different covariance functions (Zu et al. 2013), and measure lags using either spectroscopic light curves (Zu et al. 2011) or photometric light curves (Zu et al. 2016) and over a thin-disk model (Mudd et al. 2018).


## Quick Start (Windows 10)

### 1) Install prerequisites

- Docker Desktop:  
  https://www.docker.com/products/docker-desktop/

- VcXsrv (X11 server for Windows):  
  https://sourceforge.net/projects/vcxsrv/

- Windows Terminal (optional):  
  https://github.com/microsoft/terminal

---

### 2) Build

Run:

- `build-docker.ps1`

Or build manually:

```powershell
docker build -t ub18-jav:latest .
```

---

### 3) Run (with GUI)

1. Start **XLaunch** (VcXsrv) and keep it running in the system tray.  
   Recommended XLaunch option for simplicity: **Disable access control**.

2. Run:

- `run-docker-test.ps1`

Or run manually:

```powershell
docker run --rm -it -e DISPLAY=host.docker.internal:0.0 ub18-jav:latest
```

3. Run with shared folder:

- `run-docker-workspace.ps1 workspace` 

- `run-docker-workspace.ps1 C:\Astro\data` 

Or `cd C:\Astro\data`

`run-docker-workspace.ps1 .` 


4. To exit the container:

```bash
exit
```

---

## Dockerfile

```dockerfile
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root

# System deps + X11 test apps
RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran \
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    python \
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

# Build/install Javelin
WORKDIR /root/javelin-0.33
RUN python setup.py config_fc --fcompiler=gnu95 install

# Default shell
WORKDIR /root
CMD ["bash"]
```

---

## Run tests / examples inside the container

After starting the container with `DISPLAY` set, run:

```bash
cd /root/javelin-0.33/examples
python demo.py test
python plotcov.py
python demo.py show
```

If `demo.py show` / `plotcov.py` should display windows on Windows, keep using:

- `-e DISPLAY=host.docker.internal:0.0`
- VcXsrv running with **Disable access control** enabled

---

## (Optional) Save the built image as a tar file

```powershell
docker save -o ub18-jav.tar ub18-jav:latest
```