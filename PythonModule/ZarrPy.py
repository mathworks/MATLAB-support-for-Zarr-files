"""
Python wrapper module to delegate function calls to the Python tensorstore library.
The module has functions for creating Zarr files, writing to Zarr files and reading Zarr files

Copyright 2025 The MathWorks, Inc.
"""
import numpy as np
import tensorstore as ts

def createKVStore(isRemote, objPath, bucketName="") -> dict:
    """
    Creates a KV store (a python dictionary) for reading or writing
    a Zarr file
    
    Parameters:
    - isRemote (bool): whether the resource to be accessed with this 
KV store is remote (S3) or local
    - objPath (str): path to local Zarr file or to S3 object    
    - bucketName (str): If file is remote, this should be the S3 bucket 
name 
    
    Returns:
    - KVStore (dict): Key-Value store as required by tensorstore to work 
with Zarr
    """
    KVStore = dict(path=objPath);
    
    if isRemote:
        KVStore['driver'] = 's3'
        KVStore['bucket'] = bucketName
    else:
        KVStore['driver'] = 'file'

    return KVStore

def createZarr(kvstore_schema, data_shape, chunk_shape, tstoreDataType, zarrDataType, compressor, fillvalue):
    """
    Creates a new Zarr array and writes data to it.

    Parameters:
    - kvstore_schema (dictionary): Schema for the file store (local or remote)
    - data_shape (tuple): The shape of the data to be stored.
    - chunk_shape (tuple): The shape of the chunks in the Zarr file.
    - tstoreDataType (str): The data type of the data in the Tensorstore.
    - zarrDataType (str): The data type of the data in the Zarr file.
    - compressor (dictionary): The compression to be used for the Zarr array.
    - fillvalue (numeric scalar): The fill value to be used for the Zarr array.
    """
    schema = {
        'driver': 'zarr',
        'kvstore': kvstore_schema,
        'dtype': tstoreDataType,
        'metadata': {
            'shape': data_shape,
            'chunks': chunk_shape,
            'dtype':  zarrDataType,
            'fill_value': fillvalue,
            'compressor': compressor,
        },
        'create': True,
        'delete_existing': True,
    }
    zarr_file = ts.open(schema).result()
    return schema
            
def writeZarr (kvstore_schema, data):
    """
    Writes data to a Zarr file.

    Parameters:
    - kvstore_schema (dictionary): Schema for the file store (local or remote)
    - data (numpy.ndarray): The data to write to the Zarr file.
    """
    schema = {
    'driver': 'zarr',
    'kvstore': kvstore_schema
    }
    zarr_file = ts.open(schema).result()
    
    # Write data to the Zarr file
    zarr_file[...] = data


def readZarr (kvstore_schema, starts, ends, strides):
    """
    Reads a subset of data from a Zarr file.

    Parameters:
    - kvstore_schema (dictionary): Schema for the file store (local or remote)
    - starts (list): Array of start indices for each dimension (0-based)
    - ends (list): Array of end indices for each dimension (elements 
                   at the end index will not be read)
    - strides (list): Array of strides for each dimensions
    
    Returns:
    - numpy.ndarray: The subset of the data read from the Zarr file.
    """
    zarr_file = ts.open({
        'driver': 'zarr',
        'kvstore': kvstore_schema,
    }).result()
    
    # Construct the indexing slices
    slices = tuple(slice(start, end, stride) for start, end, stride in zip(starts, ends, strides))

    # Read a subset of the data
    data = zarr_file[slices].read().result()
    #data = zarr_file[...].read().result()
    return data
