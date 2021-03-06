#!/bin/bash

# s02_merge_and_qc.sh
# Merge and qc bams for a wes sample
# Alexey Larionov, 12Sep2016

# Stop at any error
set -e

# Set parameters
job_folder="/scratch/medgen/users/alexey/gastric/IGP_L1_jobs"
job_file="/scratch/medgen/users/alexey/gastric/IGP_L1_jobs/IGP_L1_02_wes_library_merge_qc_v1.job"
logs_folder="/scratch/medgen/users/alexey/gastric/IGP_L1/merged/f00_logs"
scripts_folder="/scratch/medgen/scripts/wes_pipeline_08.16/p02_wes_library_merge_and_qc"
pipeline_log="/scratch/medgen/users/alexey/gastric/IGP_L1/merged/f00_logs/a00_pipeline_gastric_IGP_L1.log"
slurm_time="--time=01:00:00"
slurm_account="--account=TISCHKOWITZ-SL2"

# Set initial working folder 
cd "${job_folder}"

# Report to pipeline log
echo "" >> "${pipeline_log}"
echo "Re-submitting job to plot summary metrics and save results to NAS" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"

# Submit job to plot summary metrics and save results to NAS
sbatch "${slurm_time}" "${slurm_account}" --qos=INTR \
       "${scripts_folder}/s03_summarise_and_save.sb.sh" \
       "${job_file}" \
       "${logs_folder}" \
       "${scripts_folder}" \
       "${pipeline_log}"

