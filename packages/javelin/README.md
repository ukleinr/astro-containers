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

- `run-docker.ps1`

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

The build recipe lives in [`Dockerfile`](./Dockerfile) — the single source of truth. This
README no longer embeds a copy (a duplicate silently drifts out of sync).

Key design notes:

- **Base image `ubuntu:18.04` is EOL** (standard support ended 2023-04) and pinned on purpose:
  JAVELIN 0.33 is Python 2.7-only, and 18.04 is the last Ubuntu shipping `python2.7` +
  `python-pip`. For a fully reproducible build, pin by digest
  (`FROM ubuntu:18.04@sha256:<digest>`); see the TODO at the top of the Dockerfile.
- **Scientific stack is pinned** to the last Python 2.7-compatible releases —
  `numpy==1.16.6`, `scipy==1.2.3`, `matplotlib==2.2.5`. Without pins the build is
  non-deterministic and breaks if a version is yanked.
- **JAVELIN provenance** — `javelin-0.33.tar.gz` is release 0.33 from
  https://github.com/nye17/javelin:
  `sha256: 7d583825c6b306600b918656c48406dcae2ae37c092a04cb7351fd1d0ccb5a68`
- **X11 test apps are optional** — `xeyes`/`xclock` are installed only to verify `DISPLAY`
  forwarding. Build with `--build-arg INSTALL_X11_APPS=false` for a leaner image.

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

---

## Security note (X11 forwarding)

The GUI path relies on VcXsrv started with **Disable access control**. This turns off X11
host-based authentication: *any* process that can reach the X server port (TCP 6000) can read
your keystrokes and screen. Acceptable on a trusted single-user workstation behind a firewall;
do **not** use it on shared or untrusted networks. Safer alternatives: run VcXsrv with access
control on and pass an `.Xauthority` cookie, or bind the X server to `localhost` only.

---

## License and attribution

This repository packages JAVELIN; it does not relicense it. The wrapper (Dockerfile, scripts,
docs) is covered by this repository's own `LICENSE`. **JAVELIN itself is distributed under its
own upstream license** — see https://github.com/nye17/javelin. If you redistribute the built
image, keep JAVELIN's license/notice intact and cite the papers listed above (Zu et al.
2011/2013/2016, Mudd et al. 2018).