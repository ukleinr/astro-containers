## What is pyPETaL?

Project repository: https://github.com/Zstone19/pypetal

> pyPETaL (a Pipeline for Estimating AGN Time Lags) is a time-series analysis pipeline for AGN
> reverberation-mapping (RM) data. It combines several popular RM tools — PyCCF, PyZDCF, JAVELIN and
> PyROA — adds outlier rejection via Damped Random Walk Gaussian-process fitting and detrending via
> the LinMix algorithm, and applies a weighting scheme across modules to mitigate aliasing in the
> time-lag distributions between light curves.

This image ships the **Python 3 core**: PyCCF, PyZDCF (with the optional **PLIKE** tool) and PyROA,
plus optional **LinMix** detrending. It runs **headless** — plots and results are written to files.

**The JAVELIN module is intentionally excluded.** JAVELIN is Python 2.7-only and conflicts with the
py3 base; run it from the separate [`packages/javelin`](../javelin) container and set `run_javelin=False`
in pyPETaL. MICA2 is also excluded (heavy optional build).

---

## Quick Start (Windows 10)

### 1) Install prerequisites

- Docker Desktop:
  https://www.docker.com/products/docker-desktop/

- Windows Terminal (optional):
  https://github.com/microsoft/terminal

No X11 server (VcXsrv) is needed — this image is headless.

---

### 2) Build

Run:

- `build-docker.ps1`

Or build manually:

```powershell
docker build -t py310-ptl:latest .
```

Build without the PLIKE Fortran tool (leaner, skips `gfortran` compile):

```powershell
docker build -t py310-ptl:latest --build-arg BUILD_PLIKE=false .
```

---

### 3) Run

- `run-docker.ps1`

Or run manually:

```powershell
docker run --rm -it py310-ptl:latest
```

Run with a shared folder (mounts a host directory at `/workspace`):

- `run-docker-workspace.ps1 workspace`

- `run-docker-workspace.ps1 C:\Astro\data`

Or `cd C:\Astro\data` then:

- `run-docker-workspace.ps1 .`

To exit the container:

```bash
exit
```

---

## Dockerfile

The build recipe lives in [`Dockerfile`](./Dockerfile) — the single source of truth.

Key design notes:

- **Base `python:3.10-slim-bookworm` pinned by digest.** Python 3.10 is the highest interpreter
  pyPETaL supports (`pyproject`: `python ">=3.8, <3.11"`). The digest makes the build reproducible;
  refresh it with `docker pull python:3.10-slim-bookworm && docker image inspect python:3.10-slim-bookworm --format '{{index .RepoDigests 0}}'`.
- **Pipeline pinned to pyPETaL 1.0.1.** Its package metadata constrains the scientific stack
  (`numpy>=1.19,<1.23`, `numba~0.56.4`, `scipy~1.10.1`, `astropy~5.2.2`, `matplotlib~3.7.1`,
  `emcee~3.1.4`, `celerite~0.4.2`, `PyROA>=3.2.1`, `pyzdcf~1.0.0`, ...). For a fully deterministic
  transitive lock, run `pip freeze` inside the built image and pin the result.
- **pyPETaL source is cloned at commit `7289d13`** (== PyPI 1.0.1) only to provide the vendored PLIKE
  Fortran source and the runnable `examples/`. The package itself is installed from PyPI.
- **LinMix pinned by commit `933dbb1`** — it has no PyPI release, so it is installed from git.
- **PLIKE is optional and network-free.** The source `plike_v4/plike_v4.0.f90` is vendored in the
  pyPETaL repo (the `wget` in `build_plike.sh` is commented out upstream); the build only compiles it
  with `gfortran`. Skip it with `--build-arg BUILD_PLIKE=false`.
- **Headless by design.** `MPLBACKEND=Agg` — no X11/DISPLAY. Point pyPETaL at `/workspace` (or any
  mounted dir) for inputs and outputs.

---

## Run examples inside the container

The pinned pyPETaL checkout ships example light curves and driver scripts under
`/root/pypetal/examples`. A minimal headless run (PyCCF + PyZDCF) looks like:

```python
import pypetal.pipeline as pl

main_dir = '/root/pypetal/examples/dat/pyzdcf_'
filenames = [main_dir + 'lc1.dat', main_dir + 'lc2.dat']
line_names = ['Continuum', 'H-alpha']
output_dir = '/workspace/pypetal_out/'

res = pl.run_pipeline(
    output_dir, filenames, line_names,
    run_pyccf=True,
    run_pyzdcf=True,
    file_fmt='csv',
    time_unit='d', lc_unit='Jy',
    lag_bounds=[-500, 500],
    verbose=True, plot=True,
)
```

To also run PLIKE (built with the default `BUILD_PLIKE=true`), pass
`run_pyzdcf=True` with `pyzdcf_params={'run_plike': True, 'plike_dir': '/root/pypetal/plike_v4/'}`.

---

## (Optional) Save the built image as a tar file

```powershell
docker save -o py310-ptl.tar py310-ptl:latest
```

---

## License and attribution

This repository packages pyPETaL; it does not relicense it. The wrapper (Dockerfile, scripts, docs)
is covered by this repository's own `LICENSE`. **pyPETaL itself is MIT-licensed** — see
https://github.com/Zstone19/pypetal. If you redistribute the built image, keep pyPETaL's license
intact and cite its bundled tools and their papers (PyCCF, PyZDCF, PyROA). **PLIKE** is the Fortran
code of Alexander (2013); see the pyZDCF documentation for its origin and licensing. **LinMix** is
by J. Meyers (https://github.com/jmeyers314/linmix).
