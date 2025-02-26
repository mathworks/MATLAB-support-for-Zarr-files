%% Test for local files
file_path = 'test_files/test_writeatt';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(5*ones(10, 10));
comp = [];
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single',...
    'Compression', comp);
zarrwrite(file_path, data);
dataR = zarrread(file_path);
% info = zarrinfo(file_path)

zarrwriteatt(file_path, 'Att1', 65);
zarrwriteatt(file_path, 'Att2', "Hello World");

temp.a = 66;
temp.b = "Hello World";
zarrwriteatt(file_path, 'Att3', temp);

zarrwriteatt(file_path, 'Att4', [10, 20, 30, 40]);

info = zarrinfo(file_path)

%% Test for remote (S3) files
file_path = 's3://mtbgeneralpurpose/abaruah/Zarrtest_files/temp6';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(5*ones(10, 10));

zarrcreate (file_path, data_shape);
zarrwrite(file_path, data);

zarrwriteatt(file_path, 'Att1', 65);
zarrwriteatt(file_path, 'Att2', "Hello World");

temp.a = 66;
temp.b = "Hello World";
zarrwriteatt(file_path, 'Att3', temp);

zarrwriteatt(file_path, 'Att4', [10, 20, 30, 40]);

info = zarrinfo(file_path)