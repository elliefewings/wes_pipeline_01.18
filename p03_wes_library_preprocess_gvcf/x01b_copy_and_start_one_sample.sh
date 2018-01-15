#!/bin/bash

# x01c_copy_and_start_one_sample.sh
# Wes library preprocess and gvcf
# Copy source files and submit sample to a node
# Alexey Larionov, 07Dec2017

# Stop at any error
set -e

# Read parameters
job_file="${1}"
scripts_folder="${2}"
pipeline_log="${3}"
sample="${4}"
run_time="${5}"

# Update pipeline log
echo "Started x01c_copy_and_start_one_sample for ${sample}: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"

# Progress report to the job log
echo "Copy and start one sample for preprocess and gvcf"
echo "Started: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# Settings
echo "====================== Settings ======================"
echo ""

source "${scripts_folder}/a01_read_config.sh"
source "${scripts_folder}/a02_report_settings.sh"

echo "====================================================="
echo ""

# ================= Copy source dedupped bams to cluster ================= #

# Suspend stopping at errors
set +e

# Progress report
echo "Started copying source dedupped bam to cluster: : $(date +%d%b%Y_%H:%M:%S)"
echo ""

# Copy bam and bai files
dedup_bam_file=$(awk -v sm="${sample}" '$1==sm {print $2}' "${merged_folder}/samples.txt")
dedup_bai_file="${dedup_bam_file%bam}bai"
  
rsync -thrqe "ssh -x" "${data_server}:${project_location}/${project}/${library}/merged/${dedup_bam_file}" "${dedup_bam_folder}/"
exit_code_1="${?}"
rsync -thrqe "ssh -x" "${data_server}:${project_location}/${project}/${library}/merged/${dedup_bai_file}" "${dedup_bam_folder}/"
exit_code_2="${?}"
  
# Stop if copying failed
if [ "${exit_code_1}" != "0" ] || [ "${exit_code_2}" != "0" ]  
then
  echo ""
  echo "Failed getting source data from NAS"
  echo "Script terminated"
  echo ""
  exit
fi

# Progress report
echo "Copied bam and bai"
echo ""

# Resume stopping at errors
set -e

# ================= Submit the sample to a node for processing ================= #

# Set time and account for pipeline submissions
slurm_time="--time=${run_time}"
slurm_account="--account=${account_process_gvcf}"

# Start pipeline on a separate node
sbatch "${slurm_time}" "${slurm_account}" \
     "${scripts_folder}/s02_preprocess_and_gvcf.sb.sh" \
     "${sample}" \
     "${job_file}" \
     "${logs_folder}" \
     "${scripts_folder}" \
     "${pipeline_log}"
  
# Progress report
echo "Submitted ${sample} for processing: $(date +%d%b%Y_%H:%M:%S)"
echo ""
  
# Update pipeline log
echo "Submitted ${sample} for repeat processing: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"
