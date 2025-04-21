[![codecov](https://codecov.io/gh/mathworks/MATLAB-support-for-Zarr-files/graph/badge.svg?token=ZBLNDOLQyA)](https://codecov.io/gh/mathworks/MATLAB-support-for-Zarr-files)

# MATLAB Support for Zarr files

[Zarr&reg;](https://zarr-specs.readthedocs.io/en/latest/specs.html) is a chunked, compressed, _N_-dimensional array storage format optimized for performance and scalability. It is widely used in scientific computing for handling large arrays efficiently.
This repository provides an interface to read and write Zarr arrays and metadata from MATLAB&reg;.

For complete documentation, refer to the `documentation.md` file, or refer to the help section of each function.

## Status
- Supports only Zarr v2.
- Supports reading and writing of Zarr arrays from local storage and Amazon S3.
- Supports reading and writing of Zarr metadata from local storage and Amazon S3.

## Setup
To use this repository, clone the repo to your local folder and add it to your MATLAB using [addpath](https://www.mathworks.com/help/matlab/ref/addpath.html).
For example, 
``` MATLAB
>> addpath("C:\<username>\support-Zarr-in-MATLAB\")
```

### MathWorks Products (https://www.mathworks.com)

Requires MATLAB release R2022b or newer

### 3rd Party Products:
- Python - v3.10 or newer
- [tensorstore](https://github.com/google/tensorstore) - v0.1.71 or newer
- [numpy](https://github.com/numpy/numpy) - v1.26.4 or newer

See the link [here](https://www.mathworks.com/support/requirements/python-compatibility.html) for the Python versions compatible with different MATLAB releases.


## Installation
Before proceeding, please ensure that you have a supported version of Python installed on your machine.
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

Once Python is installed, install the Python packages [tensorstore](https://github.com/google/tensorstore) and [numpy](https://github.com/numpy/numpy).

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
data_shape = [10,10];              % shape of the Zarr array to be written
data       = 5*ones(10,10);        % Data to be written

zarrcreate (filepath, data_shape)  % Create the Zarr array with default attributes
zarrwrite(filepath, data)          % Write data to the Zarr array
```

### Create a Zarr array and write data to it using zlib compression with non-default chunking
``` MATLAB
filepath = "myZarrfiles\singleZlibDset";

% Size of the data
data_shape = [10, 20];
% Chunk size
chunk_shape = [5, 5];
% Sample data to be written
data = single(5*ones(10, 20));

% Set the compression ID and compression level
compress.id = "zlib";
compress.level = 8;

% Create the Zarr array
zarrcreate(filepath, data_shape, ChunkSize=chunk_shape, DataType="single", ...
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
or refer to the [documentation.md](https://github.com/mathworks/MATLAB-support-for-Zarr-files/blob/main/doc/documentation.md) and [examples.md](https://github.com/mathworks/MATLAB-support-for-Zarr-files/blob/main/doc/examples.md) files.


## License
<!--- Make sure you have a License.txt within your Repo --->

The license is available in the `License.txt` file in this GitHub repository.

## Community Support
[MATLAB Central](https://www.mathworks.com/matlabcentral)

Copyright 2025 The MathWorks, Inc.
