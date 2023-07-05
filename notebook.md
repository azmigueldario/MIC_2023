## Environment setup

Login into AWS instance for the workshop

```
# chmod 600 CBW.pem
ssh -i CBW.pem ubuntu@31.uhn-hpc.ca
```

## Marker gene taxonomic analysis tutorial

Using QIIME2 on a pre-formated dataset 

```sh
# QIIME forces you to rarefy
qiime diversity alpha-rarefaction \
    --i-table deblur_output/deblur_table_final.qza \
    --p-max-depth 11536 `# input your max depth here to avoid rarefaction` \
    --p-steps 20 \
    --i-phylogeny asvs-tree.qza \
    --o-visualization rarefaction_curves.qzv


qiime diversity core-metrics-phylogenetic \
    --i-table deblur_output/deblur_table_final.qza \
    --i-phylogeny asvs-tree.qza \
    --p-sampling-depth 4000 `# here put a minimum threshold to avoid rarefaction`  \
    --m-metadata-file Blueberry_metadata_reduced.tsv \
    --p-n-jobs-or-threads 4 \
    --output-dir diversity

for input_file in $(ls diversity/*_vector.qza);
    do
    # create output file based on input
    output_file=${i/_vector.qza/_compare_groups.qzv}
    qiime diversity alpha-group-significance \
        --i-alpha-diversity $input_file \
        --m-metadata-file Blueberry_metadata_reduced.tsv \
        --o-visualization diversity/shannon_compare_groups.qzv
    done

qiime diversity alpha-group-significance \
    --i-alpha-diversity diversity/shannon_vector.qza \
    --m-metadata-file Blueberry_metadata_reduced.tsv \
    --o-visualization diversity/shannon_compare_groups.qzv
```

Differential abundance using ANCOM requires non-zero abundances, so a pseudocount of 1 must 
be added for taxa without reads in a sample (add 1)

```sh
qiime composition add-pseudocount \
    --i-table deblur_output/deblur_table_final.qza \
    --p-pseudocount 1 \
    --o-composition-table deblur_output/deblur_table_final_pseudocount.qza
```
