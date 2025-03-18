file_path = 'test_files/roundtrip.zarr';
data_shape = [10, 10];
chunk_shape = [5, 5];

data = single(magic(10));
zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single');
zarrwrite(file_path, data);
dataR = zarrread(file_path);
P = isequal(data, dataR);
Q = ~P;
R = sum(Q(:));
if(R>0)
    error("Round trip not successful!!")
end
