import tensorstore as ts
import numpy as np

def writeZarr (file_path, data_shape, chunk_shape, data, TstoreDtype, Zarrdtype):
    """
    Writes data to a Zarr file.

    Parameters:
    - file_path (str): The path where the Zarr file will be stored.
    - data_shape (tuple): The shape of the data to be stored.
    - chunk_shape (tuple): The shape of the chunks in the Zarr file.
    - data (numpy.ndarray): The data to write to the Zarr file.
    """
    zarr_file = ts.open({
        'driver': 'zarr',
        'kvstore': {
            'driver': 'file',
            'path': file_path
        },
        'dtype': TstoreDtype,
        'metadata': {
            'shape': data_shape,
            'chunks': chunk_shape,
            'dtype':  Zarrdtype,
            'fill_value': 0.0,
        },
        'create': True,
        'delete_existing': True,
    }).result()
    
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