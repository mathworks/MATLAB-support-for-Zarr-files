%% Test for double fill value
file_path = 'test_files\temp_double_FV';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = double(magic(10));

zarrcreate (file_path, data_shape, 'Datatype', 'double', 'FillValue', 10);
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path)

%% Test for default fill value
file_path = 'test_files\temp_double_defaultFV';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = double(magic(10));

zarrcreate (file_path, data_shape, 'Datatype', 'double');
zarrwrite(file_path, data);
dataR = zarrread(file_path);
info = zarrinfo(file_path)