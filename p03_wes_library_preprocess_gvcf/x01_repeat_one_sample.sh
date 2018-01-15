#!/bin/bash

# x01a_repeat_one_sample.sh
# Start preprocessing and gvcf of one sample failed in the previous batch
# Assuming the source files have been copied and the folders structure etc created
# Alexey Larionov, 08Dec2017

# Stop at any errors
set -e

# Read parameters
job_file="${1}"
scripts_folder="${2}"
sample="${3}"
run_time="${4}"

# Read job's settings
source "${scripts_folder}/a01_read_config.sh"

# --- Basic checks of what was left from the previous batch run --- #

# Check existance of the pipeline log
pipeline_log="${logs_folder}/a00_pipeline.log"
if [ ! -e ${pipeline_log} ]
then
  echo ""
  echo "Can not detect the pipeline log:"
  echo "${pipeline_log}"
  echo ""
  echo "Script terminated"
  echo ""
  exit 1
fi

# Check folders tree on cluster
if [ ! -d "${merged_folder}" ] || \
   [ ! -d "${dedup_bam_folder}" ] || \
   [ ! -d "${proc_bam_folder}" ] || \
   [ ! -d "${idr_folder}" ] || \
   [ ! -d "${bqr_folder}" ] || \
   [ ! -d "${gvcf_folder}" ] 
then
  echo ""
  echo "Can not detect the expected folders on cluster"
  echo ""
  echo "Script terminated"
  echo ""
  exit 1
fi

# Check existance of the source samples file
source_samples_file="${merged_folder}/samples.txt" 
if [ ! -e ${source_samples_file} ]
then
  echo ""
  echo "Can not detect the source samples file:"
  echo "${source_samples_file}"
  echo ""
  echo "Script terminated"
  echo ""
  exit 1
fi

# Check presence of the sample in the source samples list
sample_check1=$(awk -v smp="${sample}" '$1==smp' "${source_samples_file}")
if [ -z "${sample_check1}" ]
then
  echo ""
  echo "Can not detect sample in the source samples file"
  echo "${source_samples_file}"
  echo ""
  echo "Script terminated"
  echo ""
  exit 1
fi

# Check existance of the log of completed samples
gvcfs_list_file="${gvcf_folder}/samples.txt" 
if [ ! -e ${gvcfs_list_file} ]
then
  echo ""
  echo "Can not detect the log of completed samples:"
  echo "${gvcfs_list_file}"
  echo ""
  echo "Script terminated"
  echo ""
  exit 1
fi

# Check absence of the sample in the log of completed samples
sample_check2=$(awk -v smp="${sample}" '$1==smp' "${gvcfs_list_file}")
if [ ! -z "${sample_check2}" ]
then
  echo ""
  echo "Sample has been detected in the completed samples list:"
  echo "${gvcfs_list_file}"
  echo ""
  echo "Remove sample from the list of completed samples and try again"
  echo ""
  echo "Script terminated"
  echo ""
  exit 1
fi

# --- Submit the sample --- #

# Prepare parameters for slurm submission
slurm_time="--time=${time_copy_in}"
slurm_account="--account=${account_copy_in}"

# Submit job to cluster
sbatch "${slurm_time}" "${slurm_account}" \
       "${scripts_folder}/x01a_copy_and_start_one_sample.sb.sh" \
       "${job_file}" \
       "${logs_folder}" \
       "${scripts_folder}" \
       "${pipeline_log}" \
       "${sample}" \
       "${run_time}"

# Progress report to pipeline log
echo "" >> "${pipeline_log}"
echo "Attempting repeating of ${sample}" >> "${pipeline_log}"
echo "  Requested time: ${run_time}"  >> "${pipeline_log}"
echo "  Passed basic checks" >> "${pipeline_log}"
echo "  Submitted job to HPC: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"
