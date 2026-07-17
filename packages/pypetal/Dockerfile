# pyPETaL — AGN reverberation-mapping time-lag pipeline (Python 3).
# Modern py3 stack, so unlike packages/javelin this image is NOT legacy: it runs headless
# (matplotlib Agg backend, results written to files) and needs no X11 server.
#
# Python 3.10 is the highest interpreter pyPETaL supports (pyproject: python ">=3.8, <3.11").
# Base pinned by digest for reproducibility (tag kept for readability; digest takes precedence).
# Refresh with: docker pull python:3.10-slim-bookworm && docker image inspect python:3.10-slim-bookworm --format '{{index .RepoDigests 0}}'
FROM python:3.10-slim-bookworm@sha256:9643927a6fc74bd81b0f1bbb5cce3cb4a491f46b4c5dbee770f28e575f180015

ENV DEBIAN_FRONTEND=noninteractive \
    MPLBACKEND=Agg \
    PIP_NO_CACHE_DIR=1
WORKDIR /root

# Pinned upstream refs (reproducibility; see README design notes):
#   pyPETaL 1.0.1  -> commit 7289d13 (== PyPI 1.0.1); provides plike_v4/ + examples/
#   linmix (detrending) has no PyPI release -> pinned by commit
ARG PYPETAL_REF=7289d13e7c0fc9c51dc7212cbdcdeddb991096c3
ARG LINMIX_REF=933dbb1359dcb5404cf881bfdd5cf433b0195152
# Build the optional PLIKE Fortran tool (part of the pyZDCF module). Pass
# --build-arg BUILD_PLIKE=false to skip it — pyZDCF runs fine without PLIKE.
ARG BUILD_PLIKE=true

# System deps:
#   gfortran        - compiles the vendored PLIKE source (plike_v4/plike_v4.0.f90)
#   build-essential - source builds of C/C++ extensions with no matching wheel (e.g. celerite, PyROA)
#   git             - clone the pinned pyPETaL source (for PLIKE + examples) and pip-install linmix from git
#   ca-certificates - TLS for git/pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran \
    build-essential \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# pyPETaL source at the pinned commit — used for the vendored PLIKE Fortran source and the
# runnable examples/. NOTE: pyPETaL itself is installed from PyPI below (pinned), not from this
# checkout, to keep the resolved dependency set aligned with the published 1.0.1 release.
RUN git clone https://github.com/Zstone19/pypetal.git \
    && git -C /root/pypetal checkout ${PYPETAL_REF}

# Scientific pipeline — pinned pyPETaL 1.0.1 (its metadata constrains numpy<1.23, numba~0.56.4,
# scipy~1.10.1, astropy~5.2.2, matplotlib~3.7.1, emcee~3.1.4, celerite~0.4.2, PyROA, pyzdcf, ...).
RUN pip install "pypetal==1.0.1"

# Optional detrending via LinMix (pyPETaL "extra" group), pinned by commit — no PyPI release.
RUN pip install "linmix @ git+https://github.com/jmeyers314/linmix.git@${LINMIX_REF}"

# PLIKE: compile the in-repo Fortran source (no network — the wget in build_plike.sh is commented
# out upstream). build_plike.sh swallows compile errors, so assert the binary exists afterwards.
RUN if [ "$BUILD_PLIKE" = "true" ]; then \
      cd /root/pypetal && sh build_plike.sh && test -f plike_v4/plike; \
    fi

LABEL org.opencontainers.image.title="pypetal" \
      org.opencontainers.image.version="1.0.1" \
      org.opencontainers.image.source="https://github.com/Zstone19/pypetal" \
      org.opencontainers.image.base.name="python:3.10-slim-bookworm" \
      org.opencontainers.image.description="pyPETaL 1.0.1 (AGN reverberation-mapping time-lag pipeline, Python 3.10) — headless, PLIKE + LinMix, JAVELIN module excluded"

# Default shell
WORKDIR /root
CMD ["bash"]
