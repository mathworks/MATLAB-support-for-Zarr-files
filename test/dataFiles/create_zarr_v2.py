# Create Zarr v2 array

import zarr
import numpy as np
store = zarr.DirectoryStore('grp_v2')
group = zarr.group(store=store,overwrite=True)
group.attrs['group_description'] = 'This is a sample Zarr group'
group.attrs['group_level'] = 1
array = group.create_dataset('arr_v2',shape=(20,25),dtype=np.float32,chunks=(2,5),fillvalue=-9)
array.attrs['array_description'] = 'This is a sample Zarr array'
array.attrs['array_type'] = 'double'
array.attrs['array_level'] = 1
array[:] = np.random.rand(20,25)
