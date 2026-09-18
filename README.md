# MATLAB Support for Zarr files

[Zarr&reg;](https://zarr-specs.readthedocs.io/en/latest/specs.html) is a chunked, compressed, _N_-dimensional array storage format optimized for performance and scalability. It is widely used in scientific computing for handling large arrays efficiently.
This repository provides an interface to read and write Zarr arrays and metadata from MATLAB&reg;.

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=mathworks/MATLAB-support-for-Zarr-files)
[![View on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange)

For complete documentation, refer to [documentation.md](doc/documentation.md) or the help section of each function.

## Feedback/Requests

The direction and capabilities of this package depend on feedback from users. We encourage you to ask for what you need, and we look forward to hearing from you. See [CONTRIBUTING.md](CONTRIBUTING.md) for adding new features and bug fixing.

Create/view [issues for MATLAB Support for Zarr files](https://github.com/mathworks/MATLAB-support-for-Zarr-files/issues) here. See [Creating good issues](https://github.com/orgs/community/discussions/147722) for tips and best practices.

## Community Support

For general questions and support for MATLAB, visit [MATLAB Central](https://www.mathworks.com/matlabcentral)

## Status

- Supports only Zarr v2.
- Supports reading and writing of Zarr arrays from local storage and Amazon S3.
- Supports reading and writing of Zarr metadata from local storage and Amazon S3.

[![codecov](https://codecov.io/gh/mathworks/MATLAB-support-for-Zarr-files/graph/badge.svg?token=ZBLNDOLQyA)](https://codecov.io/gh/mathworks/MATLAB-support-for-Zarr-files)

## Setup

### Install as a toolbox

Download the latest `.mltbx` file from [Releases](https://github.com/mathworks/MATLAB-support-for-Zarr-files/releases). Open the file, or install programmatically:

``` MATLAB
matlab.addons.toolbox.installToolbox("MATLAB_Support_for_Zarr_Files.mltbx")
```

The toolbox cannot install the required Python packages for you. After installing, run `configureZarrPythonEnvironment` once to verify your Python setup and install `tensorstore` and `numpy` (see [Installation](#installation)).

### Use from source

Alternatively, clone the repo to your local folder and add it to your MATLAB path using [addpath](https://www.mathworks.com/help/matlab/ref/addpath.html):

``` MATLAB
>> addpath("C:\<username>\MATLAB-support-for-Zarr-files\toolbox")
```

### MathWorks Products (<https://www.mathworks.com>)

Requires MATLAB release R2024a or newer

## Installation

Before proceeding, please ensure that you have a supported version of Python&reg; installed on your machine.
See [MATLAB Compatible Python Versions](https://www.mathworks.com/support/requirements/python-compatibility.html) for the Python versions compatible with different MATLAB releases.

### 3rd Party Products

The following versions are required by this package:

- Python - v3.10 or newer
- [tensorstore](https://github.com/google/tensorstore) - v0.1.71 or newer
- [numpy](https://github.com/numpy/numpy) - v1.26.4 or newer

### Configuring Python

Please refer to the following links to configure your system to use Python with MATLAB:

- [Configure Your System to Use Python](https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html)
- [Access Python Modules from MATLAB - Getting Started](https://www.mathworks.com/help/matlab/matlab_external/create-object-from-python-class.html)

Make sure that the Python path is included in your system path environment variable. To verify that you have a supported version of Python, type (in MATLAB Command Window):

``` MATLAB
>> pyenv

ans = 

  PythonEnvironment with properties:

          Version: "3.11"
       Executable: "C:\Users\<username>\AppData\Local\Programs\Python\Python311\pythonw.exe"
          Library: "C:\Users\<username>\AppData\Local\Programs\Python\Python311\python311.dll"
             Home: "C:\Users\<username>\AppData\Local\Programs\Python\Python311"
           Status: NotLoaded
    ExecutionMode: OutOfProcess
```

If the value of the `Version` property is empty, then you do not have a supported version available.

Once Python is installed, install the Python packages [tensorstore](https://github.com/google/tensorstore) and [numpy](https://github.com/numpy/numpy). The quickest way is to run the bundled helper, which verifies your environment and installs the packages into it:

``` MATLAB
>> configureZarrPythonEnvironment
```

## Getting Started

1. Clone the github repo to your local drive.
2. Start MATLAB.
3. Add the parent cloned directory to your MATLAB path:

``` MATLAB
>> addpath ("C:\<username>\support-Zarr-in-MATLAB\")
```

## Examples

### Read a Zarr array

``` MATLAB
filepath = "group1\dset1";
data     = zarrread(filepath);
```

### Create and write to a Zarr array

``` MATLAB
filepath   = "myZarrfiles\singleDset";
data_size = [10,10];               % shape of the Zarr array to be written
data       = 5*ones(10,10);        % Data to be written

zarrcreate(filepath, data_size)    % Create the Zarr array with default attributes
zarrwrite(filepath, data)          % Write data to the Zarr array
```

### Create a Zarr array and write data to it using zlib compression with non-default chunking

``` MATLAB
filepath = "myZarrfiles\singleZlibDset";

% Size of the data
data_size = [10, 20];
% Chunk size
chunk_size = [5, 5];
% Sample data to be written
data = single(5*ones(10, 20));

% Set the compression ID and compression level
compress.id = "zlib";
compress.level = 8;

% Create the Zarr array

zarrcreate(filepath, data_size, ChunkSize=chunk_size, DataType="single", ...
    Compression=compress)

% Write to the Zarr array
zarrwrite(filepath, data)
```

### Read the metadata from a Zarr array

``` MATLAB
filepath = "group1\dset1";
info = zarrinfo(filepath);
```

## Help

To view documentation of a function, type `help <function_name>`. For example,

``` MATLAB
>> help zarrcreate
```

or refer to the [documentation.md](doc/documentation.md) and [examples.md](doc/examples.md) files.

## License

The license is available in the [License.txt](License.txt) file in this GitHub repository.

Copyright 2025-2026 The MathWorks, Inc.
