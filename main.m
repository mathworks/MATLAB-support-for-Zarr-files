%% Create the Zarr file
file_path = 'temp4';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(5*ones(10, 10));

zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single');
writezarr(file_path, data);
dataR = readzarr(file_path);
info = zarrinfo(file_path)


%% Write the Zarr file
file_path = 'temp3';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(5*ones(10, 10));

writezarr(file_path, chunk_shape, data);

dataR = readzarr(file_path);

%% Test for int8 datatype
file_path = 'temp_int8';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = int8(magic(10));

writezarr(file_path, chunk_shape, data);
dataR = readzarr(file_path);

isequal(data, dataR)

%% Test for uint16 datatype
file_path = 'temp_uint16';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = uint16(magic(10));

writezarr(file_path, chunk_shape, data);
dataR = readzarr(file_path);

isequal(data, dataR)

%% Test for double datatype
file_path = 'temp_double';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = double(magic(10));

writezarr(file_path, chunk_shape, data);
dataR = readzarr(file_path);

isequal(data, dataR)

%% Test for single datatype
file_path = 'temp_single';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(magic(10));

writezarr(file_path, chunk_shape, data);
dataR = readzarr(file_path);

isequal(data, dataR)

%% Test for logical datatype
% TODO: Fix boolean writing
file_path = 'temp_bool';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = (magic(10)>50);

writezarr(file_path, chunk_shape, data);
dataR = readzarr(file_path);

isequal(data, dataR)