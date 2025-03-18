"""
Python wrapper module to delegate function calls to the Python tensorstore library.
The module has functions for creating Zarr files, writing to Zarr files and reading Zarr files

Copyright 2025 The MathWorks, Inc.
"""
import tensorstore as ts
import numpy as np

def createZarr(kvstore_schema, data_shape, chunk_shape, tstoreDataType, zarrDataType, compressor, fillvalue):
    """
    Creates a new Zarr dataset and writes data to it.

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


def readZarr (kvstore_schema):
    """
    Reads a subset of data from a Zarr file.

    Parameters:
    - kvstore_schema (dictionary): Schema for the file store (local or remote)
    - subset_slice (tuple): A tuple of slice objects specifying the subset to read.
    
    Returns:
    - numpy.ndarray: The subset of the data read from the Zarr file.
    """
    zarr_file = ts.open({
        'driver': 'zarr',
        'kvstore': kvstore_schema,
    }).result()
    
    # Read a subset of the data
    data = zarr_file[...].read().result()
    return data