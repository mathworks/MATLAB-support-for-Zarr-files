%% Test 1
compression = {'zlib', 'gzip', 'bz2'};
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(5*ones(10, 10));

for index = 1:numel(compression)
    comp = compression{index};
    file_path = ['test_files/comp_test/' comp 'dset_test.zarr'];
    compstruct.id = comp;
    compstruct.level = 8;

    zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
        'Compression', compstruct);
    zarrwrite(file_path, data);
    dataR = zarrread(file_path);
    info = zarrinfo(file_path);
    fprintf("Testing: %s\n", comp);
    fprintf("Expected: %s  %d \n", compstruct.id, compstruct.level);
    fprintf("Actual: %s %d \n ", info.compressor.id, info.compressor.level);
    fprintf("---------\n");
end

% rmdir('test_files/comp_test/', 's')

%% Test 2 - testing default
file_path = 'test_files/comp_test/defaultcomp.zarr';
data_shape = [10, 10];
chunk_shape = [5, 5];

data = single(5*ones(10, 10));
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single');
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path);
info.compressor


%% Test 3 - testing 'null' compression - NEGATIVE
file_path = 'test_files/comp_test/nullcompdset.zarr';
data_shape = [10, 10];
chunk_shape = [5, 5];
compstruct.id = 'null';

data = single(5*ones(10, 10));
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
    'Compression', compstruct);
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path);
info.compressor

%% Testing compression none ([])
file_path = 'test_files/comp_test/nocompdset.zarr';
data_shape = [10, 10];
chunk_shape = [5, 5];
compstruct = [];

data = single(5*ones(10, 10));
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
    'Compression', compstruct);
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path);
info.compressor

%% Test 4 - testing 'blosc' compression 1
file_path = 'test_files/comp_test/blosc1dset.zarr';
data_shape = [10, 10];
chunk_shape = [5, 5];
compstruct2.id = 'blosc';
% compstruct.level = 4;

data = single(5*ones(10, 10));
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
    'Compression', compstruct2);
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path);
info.compressor

%% Test 5 - testing 'blosc' compression 2
file_path = 'test_files/comp_test/blosc2dset.zarr';
data_shape = [10, 10];
chunk_shape = [5, 5];
compstruct.id = 'blosc';
compstruct.clevel = 4;
compstruct.shuffle = 2;

data = single(5*ones(10, 10));
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
    'Compression', compstruct);
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path);
info.compressor

%% Test 6 - testing 'blosc' compression 3
file_path = 'test_files/comp_test/blosc3dset.zarr';
data_shape = [10, 10];
chunk_shape = [5, 5];

compstruct.id = 'blosc';
compstruct.blocksize = 78;
compstruct.clevel = 4;
compstruct.shuffle = 2;

data = single(5*ones(10, 10));
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
    'Compression', compstruct);
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path);
info.compressor

%%
file_path = 'test_files/bloscDsetFV';
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
dataR = zarrread(file_path);
info = zarrinfo(file_path);