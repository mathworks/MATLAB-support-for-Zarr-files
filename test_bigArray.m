%% Test for local files
file_path = 'test_files/test_bigArray';
data_shape = [10000, 10000];
chunk_shape = [500, 500];
data = magic(10000);
comp = [];
zarrcreate(file_path, data_shape, ChunkSize=chunk_shape,...
    Compression=comp);
zarrwrite(file_path, data);
dataR = zarrread(file_path);