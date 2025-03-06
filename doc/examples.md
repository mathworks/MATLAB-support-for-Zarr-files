# Examples

### Reading a Zarr array
```
filepath = '\group1\dset1';
data = zarrread(filepath)
```

### Creating a Zarr array and write to it with default Name-Value pairs
```
filepath = 'myZarrfiles\singleDset';
data_shape = [10, 10];           % shape of the Zarr array to be written
data = 5*ones(10, 10);   % Data to be written

zarrcreate (filepath, data_shape); % Create the Zarr array with default attributes
zarrwrite(filepath, data);         % Write 'data' to the zarr array at 'file_path' as a double array (default)
```

### Creating a Zarr array and write data to it using zlib compression with non default chunking.
```
filepath = 'myZarrfiles\singleZlibDset';

% Size of the data
data_shape = [10, 10];
% Chunk size
chunk_shape = [5, 5];
% Sample data to be written
data = single(5*ones(10, 10));

% Set the compression ID and compression level
compress.id = 'zlib';
compress.level = 8;

% Create the Zarr array
zarrcreate(filepath, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
	'Compression', compress);
	
% Write to the Zarr array
zarrwrite(filepath, data);
```


### Creating a Zarr array and write data to it using blosc compression with non default fill value.
```
file_path = 'bloscDsetFV';
data_shape = [10, 10];
chunk_shape = [5, 5];

compstruct.id = 'blosc';
compstruct.cname = 'snappy';
compstruct.clevel = 7;
compstruct.shuffle = 0;
compstruct.blocksize = 5;

data = magic(10);
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape,...
    'Compression', compstruct, 'FillValue', 42);
zarrwrite(file_path, data);
info = zarrinfo(file_path);

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
```
filepath = '\group1\dset1';
info = zarrinfo(filepath);
```


### Write a key-value pair as metadata to a Zarr array
```
% If the location pointed by 'filepath' does not have a '.zarray'
% or '.zgroup' file, an error will be thrown.
filepath = '\group1\dset1'; 
Attname = 'pi';
AttValue = 3.14;
zarrwriteatt(filepath, Attname, Attvalue);

SpeedOfSound.value = 343;
SpeedOfSound.unit = 'm/s';
zarrwriteatt(filepath, 'SpeedOfSound', SpeedOfSound);

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
