# Ubuntu 18.04 is EOL (standard support ended 2023-04) but pinned on purpose:
# JAVELIN 0.33 is Python 2.7-only, and 18.04 is the last Ubuntu shipping python2.7 + python-pip.
# Pinned by digest for reproducibility (tag kept for readability; digest takes precedence).
# Refresh with: docker pull ubuntu:18.04 && docker image inspect ubuntu:18.04 --format '{{index .RepoDigests 0}}'
FROM ubuntu:18.04@sha256:152dc042452c496007f07ca9127571cb9c29697f42acbfad72324b2bb2e43c98

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root

# Install X11 test apps (xeyes/xclock) to verify DISPLAY forwarding.
# Pass --build-arg INSTALL_X11_APPS=false for a leaner image.
ARG INSTALL_X11_APPS=true

# System deps: gfortran + BLAS/LAPACK for the JAVELIN f2py build, Python 2.7 + Tk backend for matplotlib GUI.
# python-dev supplies Python.h — required to compile C/Fortran extensions: the JAVELIN f2py build and the
# subprocess32 sdist (a matplotlib 2.2.5 dep with no py2.7 wheel), both built from source.
# python-setuptools/python-wheel are pulled explicitly: they are Recommends of python-pip (dropped by
# --no-install-recommends), and pip 9.0.1 has no build isolation, so building sdists via `setup.py`
# needs setuptools present in the system interpreter.
RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran \
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    python2.7 \
    python-dev \
    python-pip \
    python-setuptools \
    python-wheel \
    python-tk \
    ca-certificates \
    && if [ "$INSTALL_X11_APPS" = "true" ]; then \
         apt-get install -y --no-install-recommends x11-apps; \
       fi \
    && rm -rf /var/lib/apt/lists/*

# Python deps — pinned to the last releases supporting Python 2.7 for a deterministic build
# (numpy 1.16.x / scipy 1.2.x / matplotlib 2.2.x are the final py2.7-compatible lines)
RUN pip install --no-cache-dir numpy==1.16.6 scipy==1.2.3 matplotlib==2.2.5

# JAVELIN sources — https://github.com/nye17/javelin (release 0.33)
# sha256: 7d583825c6b306600b918656c48406dcae2ae37c092a04cb7351fd1d0ccb5a68
COPY javelin-0.33.tar.gz /root/
RUN tar -xvzf /root/javelin-0.33.tar.gz && rm /root/javelin-0.33.tar.gz

# Build/install JAVELIN (numpy.distutils f2py build against the pinned numpy above)
WORKDIR /root/javelin-0.33
RUN python setup.py config_fc --fcompiler=gnu95 install

LABEL org.opencontainers.image.title="javelin" \
      org.opencontainers.image.version="0.33" \
      org.opencontainers.image.source="https://github.com/nye17/javelin" \
      org.opencontainers.image.base.name="ubuntu:18.04" \
      org.opencontainers.image.description="JAVELIN 0.33 (reverberation mapping, Python 2.7) on Ubuntu 18.04"

# Default shell
WORKDIR /root
CMD ["bash"]
