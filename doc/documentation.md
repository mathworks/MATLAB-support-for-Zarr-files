# Documentation
This document highlights the usage of the MATLAB functions for reading and writing Zarr files, and for reading and writing metadata to and from Zarr arrays.

Please find examples of the usage of these functions in `examples.md`.

Please refer to `README.md` for installation instructions and third-party dependencies.
* The use of this repository requires MATLAB release R2022b or newer.
* Currently, only Zarr v2 is supported.

## `zarrcreate(FILEPATH, DATASIZE, Name=Value)`
Create a Zarr array at the path specified by `FILEPATH` and of the dimensions specified
by `DATASIZE`. If `FILEPATH` is a full path name, the function creates all intermediate groups that
do not already exist. If `FILEPATH` exists already, the contents are overwritten.
   
###	Name - Value Pairs
    Datatype                - One of "double", "single", "uint64",  
                              "int64", "uint32", "int32", "uint16", "int16",  
                              "uint8", "int8", or "string". Defaults to "double".  

    ChunkSize               - Defines chunking layout specified as an array of integers. 
                              Default is [], which specifies no chunking.  

    FillValue               - Defines the Fill value for numeric arrays.  
                              Default is [], which specifies no fill value.

    Compression             - Primary compression codec used to compress
                              the Zarr array. By default, no compression
                              is applied. To enable compression, specify
                              a struct containing an "id" field. The
                              fields for the struct are as follows:
                              "id"    - The accepted values are 'zlib', 'gzip', 
                                        'blosc', 'bz2', or 'zstd'.
                              The default is no compression.
                              Optional Fields:
                                "level" - Compression level, specified as an integer. 
                                          Valid for all but "blosc" compression.
                                          The default value is 1. The accepted
                                          integer values for different
                                          compressions are:
                                          zlib - [0, 9]
                                          gzip - [0, 9]
                                          bz2  - [1, 9]
                                          zstd - [-131072, 22]
                                "cname" - Valid only for "blosc"
                                          compression. Name of compression scheme for blosc 
                                          compression, specified as one of these values:  
                                          "blosclz", "lz4", "lz4hc", "snappy", "zlib", "zstd".
                                          "zstd" is the same scheme as "lz4".
                                "clevel" - Valid only for "blosc"
                                           compression. Compression level for blosc compression, 
                                           specified as an integer in the range [0, 9]. 
                                           The default value is 5.
                                "shuffle" - Valid only for "blosc" compression.
                                            Method for rearranging input data for blosc compression, 
                                            specified as one of these values:
                                               -1 - Automatic shuffle. The function performs a bit-wise shuffle 
                                                    if the element size is one byte and otherwise performs a byte-wise shuffle.
                                                0 - No shuffle.
                                                1 - Byte-wise shuffle.
                                                2 - Bit-wise shuffle.
                                            The default value is 0.
                                "blocksize" - Valid only for "blosc" compression.
                                              Block size for blosc compression, specified 
                                              as a nonnegative integer or inf. The default value is 0.
                      
			
## `zarrwrite(FILEPATH,DATA)`
Write the MATLAB variable data (specified by DATA) to the path specified by `FILEPATH`.
The size of `DATA` must match the size of the Zarr array specified during creation.

## `DATA = zarrread(FILEPATH)`
Retrieve all the data from the Zarr array located at `FILEPATH`.
The datatype of DATA is the MATLAB equivalent of the Zarr datatype of the array
located at `FILEPATH`.

## `INFO = zarrinfo(FILEPATH)`
Read the metadata associated with a Zarr array or group located at `FILEPATH` and return the information in a structure INFO, whose fields are the names of the metadata keys. 
If `FILEPATH` is a Zarr array (has a valid `.zarray` file), the value of `node_type` is "array"; if `FILEPATH` is a Zarr group (has a valid `.zgroup` file), the value of the field `node_type` is "group".
If you specify the `FILEPATH` as a group (intermediate directory) with no `.zgroup` file, then the function will issue an error.

## `zarrwriteatt(FILEPATH,ATTNAME,ATTVALUE)`
Write the attribute named `ATTNAME` with the value `ATTVALUE` to the Zarr array or group located at `FILEPATH`. 
The attribute is written only if a .zarray or .zgroup file exists at the location specified by `FILEPATH`.
Otherwise, the function issues an error.
