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

%%
file_path = 'test_files/roundtrip3.zarr';
data_shape = [10, 20];
chunk_shape = [2, 5];

array = zeros(10, 20);

% Fill the array with the desired pattern
for i = 1:10
    array(i, :) = i; % Set each row to its corresponding row number
end

% Alternatively, using repmat
data = repmat((1:10)', 1, 20);
data = single(data);

zarrcreate(file_path, data_shape, 'ChunkSize', chunk_shape, 'DataType', 'single');
zarrwrite(file_path, data);
dataR = zarrread(file_path);
P = isequal(data, dataR);
Q = ~P;
R = sum(Q(:));
if(R>0)
    error("Round trip not successful!!")
end

%%
filepath = 'test_files\roundtrip4.zarr';
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
