# Mock for ZarrPy.py, used for remote-array workflows.

# Copyright 2026 The MathWorks, Inc.

import numpy as np
import tensorstore as ts
import tempfile, os, shutil

_DATA_ROOT = os.path.join(tempfile.gettempdir(), 'zarr_mock_s3')

def cleanDataRoot():
    if os.path.exists(_DATA_ROOT):
        # Delete temporary folder
        shutil.rmtree(_DATA_ROOT)

def createKVStore(isRemote, objPath, bucketName=""):
    if isRemote:
        # Map s3://bucket/path → local temp directory
        localPath = os.path.normpath(os.path.join(_DATA_ROOT, bucketName, objPath))
        os.makedirs(os.path.dirname(localPath), exist_ok=True)
        return {'driver': 'file', 'path': localPath}
    else:
        return {'driver': 'file', 'path': objPath}

def createZarr(kvstore_schema, data_shape, chunk_shape, tstoreDataType, 
               zarrDataType, compressor, fillvalue):
    # Same as real ZarrPy but always uses local file driver
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

def writeZarr(kvstore_schema, data):
    # Write data to the Zarr file.
    schema = {
        'driver': 'zarr',
        'kvstore': kvstore_schema
    }
    zarr_file = ts.open(schema).result()

    zarr_file[...] = data

def readZarr(kvstore_schema, starts, ends, strides):
    # Read a subset of the data.
    zarr_file = ts.open({
        'driver': 'zarr',
        'kvstore': kvstore_schema,
    }).result()

    # Convert integer inputs to single-element lists
    if isinstance(starts, int):
        starts = [starts]
    if isinstance(ends, int):
        ends = [ends]
    if isinstance(strides, int):
        strides = [strides]

    # Construct the indexing slices
    slices = tuple(slice(start, end, stride) for start, end, stride in zip(starts, ends, strides))

    data = zarr_file[slices].read().result()
    
    return data

def getDataRoot():
    # Get local temporary folder path.
    return _DATA_ROOT