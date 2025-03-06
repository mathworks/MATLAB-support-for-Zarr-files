# Documentation
This document highlights the syntaxes of the MATLAB functions for reading and writing Zarr files, and for reading and writing metadata from/to Zarr arrays and datasets.

Please find examples of the usage of these functions in the file examples.md.

Please refer to README.md for installation instructions and third party dependencies.
* The use of this feature requires MATLAB release R2022b or newer.
* Currently, only Zarr v2 is supported. Zarr v3 is not supported at the moment.

## `zarrcreate(FILEPATH, DATASHAPE, Param1, Value1, ...)`
Create a Zarr array at the path specified by FILEPATH and of the dimensions specified
by DATASHAPE. If FILEPATH is a full path name, all intermediate groups are created if 
they don't already exist.
   
###	Parameter - Value Pairs
       'Datatype'               - May be one of 'double', 'single', 'uint64',
                                  'int64', 'uint32', 'int32', 'uint16', 'int16',  
                                  'uint8', 'int8', or 'string'. Defaults to 'double'.
       'ChunkSize'              - Defines chunking layout. Default is not chunked.
       'FillValue'              - Defines the fill value for numeric datasets.
                                  The default is no fill value, specified
                                  as [].
       'Compression'            - Primary compression codec used to
                                  compress the Zarr array. The compression
                                  needs to provided as a struct, with 'id'
                                  being a required field. The required and
                                  optional fields for compression struct
                                  are as follows:
                                  Required Fields:
                                    'id'    - The accepted values are 'zlib', 'gzip', 
                                              'blosc', 'bz2', or 'zstd'. 
                                               for no compression.
                                  Optional Fields:
                                    'level' - The compression level to
                                              use. Valid for all but
                                              'blosc' compression.
                                              compression. The default
                                              value is 1. The accepted
                                              integer values for different
                                              compressions are:
                                              zlib - [0, 9]
                                              gzip - [0, 9]
                                              bz2  - [1, 9]
                                              zstd - [-131072, 22]
                                    'cname' - Valid only for 'blosc'
                                              compression. Specifies the compression
                                              method used by 'blosc'. Accepted
                                              values are: 
                                             {'blosclz' | 'lz4' | 'lz4hc' | 'snappy' | 'zlib' | 'zstd' = 'lz4
                                    'clevel' - Valid only for 'blosc'
                                               compression. Specifies the blosc
                                               compression level to use. Accepted
                                               values are integers in the range 
                                               [0, 9]. The default is 5.
                                    'shuffle' - Valid only for 'blosc'
                                                Options for rearranging of
                                                the input data. The
                                                accepted integer values are:
                                                -1 - Automatic shuffle. Bit-wise shuffle if the element size is 1 byte, otherwise byte-wise shuffle.
                                                 0 - No shuffle
                                                 1 - Byte-wise shuffle
                                                 2 - Bit-wise shuffle
                                    'blocksize' - Valid only for 'blosc'
                                                  Specifies the blosc
                                                  blocksize. Accepted
                                                  values are integer in
                                                  the range [0 inf]. The
                                                  default value is 0.
												  
			
## `zarrwrite(FILEPATH, DATA)`
Write the MATLAB variable data (specified by DATA) at the path specified by FILEPATH.
The size of DATA must match the size of the Zarr array specified during creation.

## `DATA = zarrread(FILEPATH)`
Retrieves all the data from the Zarr array located at FILEPATH.
The datatype of DATA is the MATLAB equivalent of the Zarr datatype of the array
located at FILEPATH.

## `INFO = zarrinfo(FILEPATH)`
Reads the metadata associated with a Zarr array or group located at FILEPATH, and returns the information in a structure INFO, whose fields are the names of the metdata keys. 
If FILEPATH is a Zarr array (has a valid `.zarray` file), the value of the field `node_type` is "array". If FILEPATH is a Zarr group (has a valid `.zgroup`), the value of the field `node_type` is "group".
Specifying the FILEPATH as a group (intermediate directory) with no `.zgroup` file will throw an error.

## `zarrwriteatt(FILE_PATH,ATTNAME,ATTVALUE)`
writes the attribute named ATTNAME with the value ATTVALUE to the Zarr array or group located at FILE_PATH. 
The attribute is recorded only if a .zarray or .zgroup file already exists at the location specified by FILE_PATH.
Otherwise, an error is thrown.