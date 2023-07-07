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
    output_file=${input_file/_vector.qza/_compare_groups.qzv}
    qiime diversity alpha-group-significance \
        --i-alpha-diversity $input_file \
        --m-metadata-file Blueberry_metadata_reduced.tsv \
        --o-visualization $output_file
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

## add category metadata-column
qiime composition ancom \
    --i-table deblur_output/deblur_table_final_pseudocount.qza \
    --m-metadata-file Blueberry_metadata_reduced.tsv \
    --m-metadata-column Description_3 \
    --output-dir ancom_output

```

## Metagenomics analysis

```sh
# removed the dry run to actually run it
parallel -j 1 --eta 'kraken2 --db  ~/CourseData/MIC_data/metagenome_data/k2_pluspf_08gb_20230314/ --threads 4 --output kraken2_outraw/{1/.}_{2}_minikraken.kraken.txt --report kraken2_kreport/{1/.}_{2}_minikraken.kreport --use-names {1} --confidence {2}' ::: cat_reads/*.fastq ::: 0.0 0.1

# check alignment of a sequence in a sample
cat mmseqs_m8_files/mmseqs-BB198-s1.m8 | \
    grep "SRR8742630.234641" | wc -l

# retain top hit for every sequence inside the samples
mkdir mmseqs_U90_out_tophit
cp -r ~/CourseData/MIC_data/metagenome_data/Functional_Helper_Scripts/ .
python Functional_Helper_Scripts/pick_uniref_top_hit.py --unirefm8Dir mmseqs_m8_files --output_path mmseqs_U90_out_tophit
```

```sh
column -ts $'\t'  metagenome_assemblies/KGHS_1-0/quast_scaffolds/transposed_report.tsv | less -S

prokka --metagenome --outdir output/refined_bins/KGHS_1-0/KGHS_1-0_bin.1/prokka --prefix KGHS_1-0_bin.1 refined_bins/KGHS_1-0/KGHS_1-0_bin.1/prokka/KGHS_1-0_bin.1.fa --cpus 4 --rfam 1 –-force
```