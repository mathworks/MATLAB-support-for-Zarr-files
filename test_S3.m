%% Write the Zarr file to S3
file_path = 's3://mtbgeneralpurpose/abaruah/Zarrtest_files/temp5';
data_shape = [10, 10];
chunk_shape = [5, 5];
data = single(5*ones(10, 10));

zarrcreate (file_path, data_shape);
zarrwrite(file_path, data);

dataR = zarrread(file_path);
info = zarrinfo(file_path);