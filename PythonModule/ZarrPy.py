"""
Python wrapper module to delegate function calls to the Python tensorstore library.
The module has functions for creating Zarr files, writing to Zarr files and reading Zarr files

Copyright 2025 The MathWorks, Inc.
"""
import tensorstore as ts
import numpy as np

def createZarr(file_path, data_shape, chunk_shape, tstoreDataType, zarrDataType, compressor, fillvalue):
    """
    Creates a new Zarr dataset and writes data to it.

    Parameters:
    - file_path (str): The path where the Zarr file will be stored.
    - data_shape (tuple): The shape of the data to be stored.
    - chunk_shape (tuple): The shape of the chunks in the Zarr file.
    - tstoreDataType (str): The data type of the data in the Tensorstore.
    - zarrDataType (str): The data type of the data in the Zarr file.
    - compressor (dictionary): The compression to be used for the Zarr array.
    """
    print(type(compressor))
    print(compressor)
   
    schema = {
        'driver': 'zarr',
        'kvstore': {
            'driver': 'file',
            'path': file_path
        },
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
            
def writeZarr (file_path, data):
    """
    Writes data to a Zarr file.

    Parameters:
    - file_path (str): The path where the Zarr file will be stored.
    - data (numpy.ndarray): The data to write to the Zarr file.
    """
    schema = {
    'driver': 'zarr',
    'kvstore': {
        'driver': 'file',
        'path': file_path,
    }
    }
    zarr_file = ts.open(schema).result()
    
    # Write data to the Zarr file
    zarr_file[...] = data


def readZarr (file_path):
    """
    Reads a subset of data from a Zarr file.

    Parameters:
    - file_path (str): The path to the Zarr file.
    - subset_slice (tuple): A tuple of slice objects specifying the subset to read.
    
    Returns:
    - numpy.ndarray: The subset of the data read from the Zarr file.
    """
    zarr_file = ts.open({
        'driver': 'zarr',
        'kvstore': {
            'driver': 'file',
            'path': file_path
        },
    }).result()
    
    # Read a subset of the data
    data = zarr_file[...].read().result()
    return data