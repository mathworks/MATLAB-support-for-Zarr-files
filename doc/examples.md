# Examples

### Read a Zarr array
``` MATLAB
filepath = "group1\dset1";
data = zarrread(filepath)
```

### Read a subset of Zarr array
Read a 2x2 subset of a 3x4 array, starting with the second element in the second dimension, and only reading every other element in the second dimension.
``` MATLAB
filepath = "grp_v2/smallArr";
d = zarrread(filepath, Start=[1,2], Stride=[1,2], Count=[2,2])

d =

     4    10
     5    11
```

### Create and write to a Zarr array
``` MATLAB
filepath   = "myZarrfiles\singleDset";
data_size = [10,10];               % shape of the Zarr array to be written
data       = 5*ones(10,10);        % Data to be written

zarrcreate(filepath, data_size)    % Create the Zarr array with default attributes
zarrwrite(filepath, data)          % Write "data" to the zarr array at "filepath" as a double array (default)
```

### Create a Zarr array and write data to it using zlib compression with non-default chunking.
``` MATLAB
filepath = "myZarrfiles\singleZlibDset";

% Size of the data
data_size = [10,10];
% Chunk size
chunk_size = [5,5];
% Sample data to be written
data = single(5*ones(10,10));

% Set the compression ID and compression level
compress.id = "zlib";
compress.level = 8;

% Create the Zarr array
zarrcreate(filepath, data_size, ChunkSize=chunk_size, DataType="single", ...
	Compression=compress)
	
% Write to the Zarr array
zarrwrite(filepath, data)
```


### Create a Zarr array and write data to it using blosc compression with non-default fill value
``` MATLAB
filepath = "bloscDsetFV";
data_size = [10,10];
chunk_size = [5,5];

compstruct.id = "blosc";
compstruct.cname = "snappy";
compstruct.clevel = 7;
compstruct.shuffle = 0;
compstruct.blocksize = 5;

data = magic(10);
zarrcreate(filepath, data_size, ChunkSize=chunk_size,...
    Compression=compstruct, FillValue=42)
zarrwrite(filepath, data)
info = zarrinfo(filepath);

>> info.fill_value

ans =

    42

>> info.compressor

ans = 

  struct with fields:

    blocksize: 5
       clevel: 7
        cname: 'snappy'
           id: 'blosc'
      shuffle: 0
```


### Read the metadata from a Zarr array
``` MATLAB
filepath = "group1\dset1";
info = zarrinfo(filepath);
```


### Write a key-value pair as metadata to a Zarr array
``` MATLAB
% If the location pointed by "filepath" does not have a ".zarray"
% or ".zgroup" file, the function issues an error.
filepath = "group1\dset1"; 
Attname = "pi";
AttValue = 3.14;
zarrwriteatt(filepath, Attname, Attvalue)

SpeedOfSound.value = 343;
SpeedOfSound.unit = "m/s";
zarrwriteatt(filepath, "SpeedOfSound", SpeedOfSound)

info = zarrread(filepath);

>> info.pi

ans =

    3.1400

>> info.SpeedOfSound

ans = 

  struct with fields:

    value: 343
     unit: 'm/s'
```
