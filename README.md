## Description

This document overviews the steps performed for generating an input JSON and running the single cell filtering workflow

A synology NAS storing input data was mounted on the local machine at path `mnt_path`

### Containerization

The image for running the workflow can be built with `make build` in repo directory

### Generating Input JSON


```python
from importlib import reload
import os
import json
from glob import glob

mnt_path = '/data/projects/genentech-jp'
data_dir = os.path.join(mnt_path, 'cellranger_output')

h5_files = glob(os.path.join(data_dir, "*", "*.h5"))
donor_ids = [i.split('/')[-2] for i in h5_files]
donor_counts = list(zip(donor_ids, h5_files))
```


```python
assert(all([os.path.exists(i) for i in h5_files]))
```


```python
output_dir = os.path.join(mnt_path, 'results')
input_json = {'donor_ids': donor_ids, 'donor_counts': h5_files, 'output_dir': output_dir}

with open('/home/debian/genentech-jp/scrna_filter_input.json', 'w') as fh:
    json.dump(input_json, fh, indent=2)
    
print(json.dumps(input_json, indent=2))
```

    {
      "donor_ids": [
        "MantonBM6_HiSeq_1",
        "MantonBM7_HiSeq_1",
        "MantonBM4_HiSeq_1",
        "MantonBM5_HiSeq_1",
        "MantonBM1_HiSeq_1",
        "MantonBM2_HiSeq_1",
        "MantonBM3_HiSeq_1",
        "MantonBM8_HiSeq_1"
      ],
      "donor_counts": [
        "/data/projects/genentech-jp/cellranger_output/MantonBM6_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/genentech-jp/cellranger_output/MantonBM7_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/genentech-jp/cellranger_output/MantonBM4_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/genentech-jp/cellranger_output/MantonBM5_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/genentech-jp/cellranger_output/MantonBM1_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/genentech-jp/cellranger_output/MantonBM2_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/genentech-jp/cellranger_output/MantonBM3_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/genentech-jp/cellranger_output/MantonBM8_HiSeq_1/raw_feature_bc_matrix.h5"
      ],
      "output_dir": "/data/projects/genentech-jp/results"
    }


### Running Workflow

The workflow file `wdl/scrna_filter.wdl` was run using _miniwdl_ as the execution engine of choice.

```
cd /home/debian/genentech-jp
miniwdl run wdl/scrna_filter.wdl -i scrna_filter_input.json -d /data/projects/genentech-jp/runs
```
