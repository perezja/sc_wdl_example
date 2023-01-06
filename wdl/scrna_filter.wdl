version 1.0

task scRNAFilterCells {

    input {
        File h5_count
        String prefix
    }

    command {
        /opt/scrna_filter_cells.R ~{h5_count} ~{prefix}
    }

    runtime {
        cpu: 2
        memory: '20G'
        container: 'docker.io/apollodorus/genentech-jp:v1'
    }

    output {
        File count_matrix_h5ad = prefix + "_counts.h5ad"
        File umap_png = prefix + "_umap.png"
        File gene_rank_png = prefix + "_gene_ranks.png"
    }
}

workflow scrna_filter_cells {
    input {
        Array[String] donor_ids
        Array[File] donor_counts
    }

    Array[Pair[String, File]] donor_pairs = zip(donor_ids, donor_counts)

    scatter (count_data in donor_pairs) {
        call scRNAFilterCells {
            input:
                h5_count = count_data.right, 
                prefix = count_data.left,
        }
    }
}
