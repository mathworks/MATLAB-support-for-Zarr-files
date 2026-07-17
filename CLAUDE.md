# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

MATLAB interface for reading and writing Zarr v2 arrays and metadata, from both local storage and Amazon S3. The MATLAB layer delegates the actual Zarr I/O to Google's [tensorstore](https://github.com/google/tensorstore) Python library, which it calls through MATLAB's `py.` Python bridge.

## Architecture

The codebase is a three-language stack. Data and type information flow across all three layers, so a change to the data path usually touches each:

1. **User-facing MATLAB functions** (`zarrread.m`, `zarrwrite.m`, `zarrcreate.m`, `zarrinfo.m`, `zarrwriteatt.m`) — thin wrappers that do `arguments`-block input validation and construct a `Zarr` object. These are the documented public API.

2. **`Zarr.m`** — the central gateway class (`classdef Zarr < handle`). It owns the connection between MATLAB and Python: bootstrapping the Python module path (`pySetup`/`ZarrPy`), building the tensorstore KVStore schema (local `file` driver vs. S3 `s3` driver), resolving/creating paths and Zarr groups, validating partial-read parameters, and converting between MATLAB and numpy arrays. Most non-trivial logic lives here as static helper methods.

3. **`PythonModule/ZarrPy.py`** — a small wrapper over tensorstore. Exposes `createKVStore`, `createZarr`, `writeZarr`, `readZarr`. This is the only code that talks to tensorstore directly. `Zarr.m` imports it via `py.importlib.import_module('ZarrPy')` after inserting `PythonModule/` onto `py.sys.path`.

### Key cross-cutting concerns

- **Datatype mapping** (`ZarrDatatype.m`): a single class holds three parallel arrays mapping MATLAB types ↔ tensorstore types ↔ Zarr dtype strings (e.g. `"double"` ↔ `"float64"` ↔ `"<f8"`). Construct via the static `fromMATLABType` / `fromTensorstoreType` / `fromZarrType` methods, never the private constructor. Any new supported datatype must be added to all three arrays in lockstep.

- **Index convention conversion**: MATLAB is 1-based and uses *count*; tensorstore is 0-based and uses *end index* (exclusive). The translation happens in `Zarr.read` (`start = start - 1`, `endInds = start + stride.*count`). Partial-read validation (Start/Stride/Count bounds, scalar-into-vector indexing) is in `Zarr.processPartialReadParams`.

- **Local vs. remote (S3)**: `obj.isRemote` is detected from an IRI prefix on the path. S3 URLs/URIs in six different formats are parsed into bucket + object path by `Zarr.extractS3BucketNameAndPath`. Some validity checks (e.g. `isZarrArray`) are skipped for `http`-style remote paths because they would fail even on valid arrays.

- **Zarr metadata files**: `.zarray` marks an array, `.zgroup` marks a group, `.zattrs` holds user-defined attributes (all Zarr v2, read/written as JSON). `zarr.json` is the Zarr v3 metadata file — it is detected by `zarrinfo` but writing v3 is not supported. `zarrinfo.m` reads these JSON files directly in MATLAB (not via Python); creating group hierarchies writes `.zgroup` files directly too.

## Commands

There is no build step — it's interpreted MATLAB plus a Python module on the path.

**Run the full test suite** (from the `test/` directory, since tests resolve data paths relative to `pwd`):

```matlab
cd test
results = runtests('IncludeSubfolders', true)
```

**Run a single test class or method:**

```matlab
cd test
runtests('tZarrRead')                       % one class
runtests('tZarrRead/verifyPartialArrayData') % one method
```

CI (`.github/workflows/test_setup.yml`) runs `matlab-actions/run-tests` with `select-by-folder: 'test'` across Ubuntu/Windows/macOS and MATLAB R2024a + latest.

## Setup requirements

- MATLAB R2024a or newer. Add the repo root to the MATLAB path (`addpath`).
- Python 3.10+ configured for MATLAB (`pyenv`), with `numpy` and `tensorstore` installed (see `PythonModule/requirements.txt`; CI pins `tensorstore==0.1.71`, the minimum supported version).

When iterating on `ZarrPy.py`, MATLAB caches the imported module. Reload with `Zarr.pyReloadInProcess()` (after `clear classes`) for in-process Python, or `terminate(pyenv)` for out-of-process.

## Tests

xUnit-style classes (`matlab.unittest.TestCase`) named `t<Feature>.m` in `test/`. They inherit shared fixtures from `SharedZarrTestSetup.m`, which adds the parent source folder to the path and copies `test/dataFiles/` into a `WorkingFolderFixture` so write tests don't pollute the repo. Read-test fixtures live in `test/dataFiles/grp_v2` (and `grp_v3`); expected results are stored in `expZarrArrData.mat` / `expZarrArrInfo.mat`.

## Conventions

- All error messages use `error("MATLAB:<area>:<id>", ...)` identifiers — match the existing namespacing when adding new ones.
- Function help text is the block comment directly under the signature; keep it current since the README points users to `help <function>`.
- Spelling is checked in CI by codespell (`.codespellrc`); add false positives to `ignore-words-list`.
