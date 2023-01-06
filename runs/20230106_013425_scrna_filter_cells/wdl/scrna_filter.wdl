version 1.0

task scRNAFilterCells {

    input {
        File h5_count
        String prefix
        String output_dir
    }

    command {
        /opt/scrna_filter_cells.R ~{h5_count} ~{prefix} -o ~{output_dir}
    }

    runtime {
        cpu: 2
        memory: '12G'
        container: 'docker.io/apollodorus/genentech-jp:v1'
    }

    output {
        File count_matrix_h5ad = output_dir + "/" + prefix + "_counts.h5ad"
        File umap_png = output_dir + "/" + prefix + "_umap.png"
        File gene_rank_png = output_dir + "/" + prefix + "_gene_ranks.png"
    }
}

workflow scrna_filter_cells {
    input {
        Array[String] donor_ids
        Array[File] donor_counts
        String output_dir
    }

    Array[Pair[String, File]] donor_pairs = zip(donor_ids, donor_counts)

    scatter (count_data in donor_pairs) {
        call scRNAFilterCells {
            input:
                h5_count = count_data.right, 
                prefix = count_data.left,
                output_dir = output_dir 
        }
    }
}
