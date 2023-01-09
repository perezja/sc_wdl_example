## Description

This document overviews the steps performed for generating an input JSON and running an example single cell QC and filtering workflow.

A synology NAS storing input data was mounted on the local machine at path `mnt_path`.

### Containerization

The image for running the workflow can be built with `make build` in the head repo directory.

### Generating Input JSON


```python
from importlib import reload
import os
import json
from glob import glob

mnt_path = '/data/projects/sc_wdl_example'
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
input_json = {'donor_ids': donor_ids, 'donor_counts': h5_files}

with open('/home/debian/sc_wdl_example/scrna_filter_input.json', 'w') as fh:
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
        "/data/projects/sc_wdl_example/cellranger_output/MantonBM6_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/sc_wdl_example/cellranger_output/MantonBM7_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/sc_wdl_example/cellranger_output/MantonBM4_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/sc_wdl_example/cellranger_output/MantonBM5_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/sc_wdl_example/cellranger_output/MantonBM1_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/sc_wdl_example/cellranger_output/MantonBM2_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/sc_wdl_example/cellranger_output/MantonBM3_HiSeq_1/raw_feature_bc_matrix.h5",
        "/data/projects/sc_wdl_example/cellranger_output/MantonBM8_HiSeq_1/raw_feature_bc_matrix.h5"
      ]
    }


### Running Workflow

The workflow file `wdl/scrna_filter.wdl` was run using _miniwdl_ as the execution engine of choice. All output files and run logs were written to the path specified by `-d` parameter. 

```
miniwdl run wdl/scrna_filter.wdl -i scrna_filter_input.json -d /data/projects/sc_wdl_example/results
```

This yields the output JSON acquired below.

```python
output_json = '/data/projects/sc_wdl_example/results/_LAST/outputs.json'
with open(output_json, 'r') as fh:
    outputs = json.load(fh)
    
print(json.dumps(outputs, indent=2))
```

    {
      "scrna_filter_cells.scRNAFilterCells.count_matrix_h5ad": [
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.count_matrix_h5ad/0/MantonBM6_HiSeq_1_counts.h5ad",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.count_matrix_h5ad/1/MantonBM7_HiSeq_1_counts.h5ad",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.count_matrix_h5ad/2/MantonBM4_HiSeq_1_counts.h5ad",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.count_matrix_h5ad/3/MantonBM5_HiSeq_1_counts.h5ad",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.count_matrix_h5ad/4/MantonBM1_HiSeq_1_counts.h5ad",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.count_matrix_h5ad/5/MantonBM2_HiSeq_1_counts.h5ad",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.count_matrix_h5ad/6/MantonBM3_HiSeq_1_counts.h5ad",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.count_matrix_h5ad/7/MantonBM8_HiSeq_1_counts.h5ad"
      ],
      "scrna_filter_cells.scRNAFilterCells.gene_rank_png": [
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.gene_rank_png/0/MantonBM6_HiSeq_1_gene_ranks.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.gene_rank_png/1/MantonBM7_HiSeq_1_gene_ranks.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.gene_rank_png/2/MantonBM4_HiSeq_1_gene_ranks.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.gene_rank_png/3/MantonBM5_HiSeq_1_gene_ranks.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.gene_rank_png/4/MantonBM1_HiSeq_1_gene_ranks.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.gene_rank_png/5/MantonBM2_HiSeq_1_gene_ranks.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.gene_rank_png/6/MantonBM3_HiSeq_1_gene_ranks.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.gene_rank_png/7/MantonBM8_HiSeq_1_gene_ranks.png"
      ],
      "scrna_filter_cells.scRNAFilterCells.umap_png": [
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.umap_png/0/MantonBM6_HiSeq_1_umap.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.umap_png/1/MantonBM7_HiSeq_1_umap.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.umap_png/2/MantonBM4_HiSeq_1_umap.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.umap_png/3/MantonBM5_HiSeq_1_umap.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.umap_png/4/MantonBM1_HiSeq_1_umap.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.umap_png/5/MantonBM2_HiSeq_1_umap.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.umap_png/6/MantonBM3_HiSeq_1_umap.png",
        "/data/projects/sc_wdl_example/results/20230106_122241_scrna_filter_cells/out/scRNAFilterCells.umap_png/7/MantonBM8_HiSeq_1_umap.png"
      ]
    }



```python
import shutil
output_keys = ['scrna_filter_cells.scRNAFilterCells.gene_rank_png', 'scrna_filter_cells.scRNAFilterCells.umap_png']
os.makedirs('results', exist_ok=True)
for k,v in outputs.items():
    if k in output_keys:
        for outfile in outputs[k]:
            shutil.copy(outfile, 'results')
```

### Submission

Submitted files are relative to head of repo directory.

  - Source code: `Dockerfile` and `wdl/scrna_filter.wdl`
  - script: `src/scrna_filter_cells.R`
  - UMAP and gene rank plots: `results` directory
