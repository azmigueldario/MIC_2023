#!/bin/bash
#SBATCH --job-name="run_metawrap_bin_refinement_job_array"
#SBATCH --partition=synergy,cpu2022,cpu2023
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=14
#SBATCH --time=7-00:00:00
#SBATCH --mem=60G
#SBATCH --array=1-4%4
#SBATCH --output=run_metawrap_bin_refinement_job_array.%A_%a.out
#SBATCH --error=run_metawrap_bin_refinement_job_array.%A_%a.err

# Get the bashrc information for conda.
source ~/.bashrc

# The number of cpu threads for metawrap bin refinement module..
num_threads=14

# The completeness threshold to filter the refined bins using metawrap.
completeness_thresh=50

# The contamination threshold to filter the refined bins using metawrap.
contamination_thresh=10

# The path to the checkm database.
checkm_database="software_dir/checkm_data_dir"

# The list of sample ids.
list_file="KGHS_pilot_subset_4_sample_list.txt"

# Internal Field Separator (IFS) used when using cat in a job array so that lines are separated by newlines instead of separated based on spaces.
IFS=$'\n' 

# Making an bash array based on the list file.
array=($(<$list_file))

# The sample id entry.
sample_id=${array[$SLURM_ARRAY_TASK_ID-1]}

# The initial binning directory.
binning_dir="initial_binning"

# The metabat2 bin directory.
metabat2_bin_dir="${binning_dir}/${sample_id}/metabat2"

# The maxbin2 bin directory.
maxbin2_bin_dir="${binning_dir}/${sample_id}/maxbin2"

# The bin refinement directory for refined bins using metawrap.
bin_refinement_dir="bin_refinement"
mkdir -p $bin_refinement_dir

# The sample bin refinement directory for refined bins for each sample.
sample_bin_refinement_dir="${bin_refinement_dir}/${sample_id}"

# Activate the metawrap bin_refinement conda environment.	 
conda activate metawrap_bin_refinement_env

# Set the path for the checkm database.
echo "echo \"${checkm_database}\" | checkm data setRoot"
echo "${checkm_database}" | checkm data setRoot

# Run the metawrap bin refinement command on the metabat2, maxbin2 and solidbin bins for each sample.
echo "metawrap bin_refinement -o ${sample_bin_refinement_dir} -t ${num_threads} -A ${metabat2_bin_dir} -B ${maxbin2_bin_dir} -c ${completeness_thresh} -x ${contamination_thresh}"
metawrap bin_refinement -o ${sample_bin_refinement_dir} -t ${num_threads} -A ${metabat2_bin_dir} -B ${maxbin2_bin_dir} -c ${completeness_thresh} -x ${contamination_thresh}

