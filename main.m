%% Create the Zarr file
file_path = 'test_files/nulldset5';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(5*ones(10, 10));
comp.id = 'null';
comp.level = 5;
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
    'Compression', comp);
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path)
info.compressor


%% Write the Zarr file
file_path = 'test_files\temp3';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(5*ones(10, 10));

zarrcreate (file_path, data_shape);
zarrwrite(file_path, data);

dataR = zarrread(file_path);

%% Test for int8 datatype
file_path = 'test_files\temp_int8';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = int8(magic(10));

zarrcreate (file_path, data_shape, 'Datatype', 'int8');
zarrwrite(file_path, data);
dataR = zarrread(file_path);

isequal(data, dataR)

%% Test for uint16 datatype
file_path = 'test_files\temp_uint16';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = uint16(magic(10));

zarrcreate (file_path, data_shape, 'Datatype', 'uint16');
zarrwrite(file_path, data);
dataR = zarrread(file_path);

isequal(data, dataR)

%% Test for double datatype
file_path = 'test_files\temp_double';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = double(magic(10));

zarrcreate (file_path, data_shape, 'Datatype', 'double');
zarrwrite(file_path, data);
dataR = zarrread(file_path);

isequal(data, dataR)

%% Test for single datatype
file_path = 'test_files\temp_single';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(magic(10));

zarrcreate (file_path, data_shape, 'Datatype', 'single');
zarrwrite(file_path, data);
dataR = zarrread(file_path);

isequal(data, dataR)

%% Test for logical datatype
% TODO: Fix boolean writing
file_path = 'test_files\temp_bool';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = (magic(10)>50);

zarrcreate (file_path, data_shape, 'Datatype', 'logical');
zarrwrite(file_path, data);
dataR = zarrread(file_path);

isequal(data, dataR)