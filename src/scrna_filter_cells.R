#!/usr/bin/env Rscript
suppressMessages(library(argparse))

parser <- ArgumentParser(description="Run QC and filtering for sc-RNA 10x data")
parser$add_argument("h5", type="character", help="Feature counts `i.e., *peak_bc_matrix.h5`")
parser$add_argument("prefix", type="character", help="Output prefix")
parser$add_argument("--min_expressed", type="integer", default = 500, help="Minimum number of expressed features allowed per cell")
parser$add_argument("--max_expressed", type="integer", default = 6000, help="Maximum number of expressed features allowed per cell")
parser$add_argument("--max_mito_perc", type="double", default=10, help="Filter cells based on percentage of reads sourced from mitochondrial genes")
parser$add_argument("--min_features_percent_pos", type="double", default=0.05, help="Filter features based on minimum percentage of cells expressed")
parser$add_argument("--n_variable_features", type="integer", default=2000, help="Number of variable features to find for each cluster")
parser$add_argument("--n_pcs", type="integer", default=50, help="Number of components for dimensional reduction")
parser$add_argument("--knn_param", type="integer", default=100, help="Number of nearest neighbors")
parser$add_argument("-o", "--output_dir", type="character", default=getwd(), help="Output directory")

args <- parser$parse_args()

suppressMessages(library(Seurat))
suppressMessages(library(SeuratDisk))
suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(glue))
suppressMessages(library(logger))

counts <- Read10X_h5(args$h5)
sobj <- CreateSeuratObject(counts = counts)

# cell selection
flt_cells <- WhichCells(sobj, expression = nFeature_RNA >= args$min_expressed & 
                          nFeature_RNA < args$max_expressed)

sobj$mitoPerc <- PercentageFeatureSet(object = sobj, pattern = "^MT-")
flt_cells <- intersect(flt_cells,
                       colnames(sobj)[sobj$mitoPerc < args$max_mito_perc]
)

# feature selection
ncells <- length(colnames(sobj))
counts <- GetAssayData(object = sobj, slot = "counts")
nonzero <- counts > 0
pct_expressed <- Matrix::rowSums(nonzero)/ncells
pct_expressed <- pct_expressed[pct_expressed >= (args$min_features_percent_pos/100)]
flt_features <- names(pct_expressed)

sobj_filtered <- sobj[flt_features, flt_cells]


# clustering pipeline
sobj_filtered <- Seurat::NormalizeData(sobj_filtered, normalization.method = "LogNormalize", 
                                       scale.factor = 100000, 
                                       verbose = TRUE)
sobj_filtered <- Seurat::ScaleData(sobj_filtered)
sobj_filtered <- Seurat::FindVariableFeatures(sobj_filtered, 
                                              selection.method = "vst", 
                                              nfeatures = args$n_variable_features)
sobj_filtered <- Seurat::RunPCA(sobj_filtered, pcs.compute = args$n_pcs)
sobj_filtered <- Seurat::FindNeighbors(sobj_filtered, k.param = args$knn_param, 
                                       reduction='pca', dims=1:args$n_pcs)
sobj_filtered <- Seurat::FindClusters(sobj_filtered, algorithm = 4, resolution = 1.3)
sobj_filtered <- Seurat::RunUMAP(sobj_filtered, dims = 1:args$n_pcs)

# cluster markers
markers <- Seurat::FindAllMarkers(sobj_filtered, only.pos = T, test.use = "wilcox")

# counts matrix
outfile <- file.path(args$output_dir, paste0(args$prefix, '_counts.h5Seurat'))
SaveH5Seurat(sobj_filtered, filename = outfile)
Convert(outfile, dest = "h5ad")

# gene rank plot
top_markers <- markers %>% filter(avg_log2FC > 1) %>% group_by(cluster) %>% slice_max(n = 15, order_by = avg_log2FC) %>% as.data.frame()
g1 <- DoHeatmap(sobj_filtered, features = top_markers$gene) + theme(text = element_text(size = 8))

outfile <- file.path(args$output_dir, paste0(args$prefix, '_gene_ranks.png'))
png(outfile, width = 600, height = 1200)
print(g1)
dev.off()

# umap
g2 <- DimPlot(sobj_filtered, reduction = "umap", label = TRUE, pt.size = 0.5) 
outfile <- file.path(args$output_dir, paste0(args$prefix, '_umap.png'))
png(outfile, width = 600, height = 600)
print(g2)
dev.off()
