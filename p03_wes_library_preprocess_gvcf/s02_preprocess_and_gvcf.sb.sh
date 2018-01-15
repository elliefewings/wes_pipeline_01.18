#!/bin/bash

## s02_preprocess_and_gvcf.sb.sh
## Bam preprocessing and making gvcf for a wes sample
## SLURM submission script
## Ellie Fewings; 21Dec17

#SBATCH -J preprocess_and_gvcf
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mail-type=ALL
#SBATCH --no-requeue
#SBATCH -p skylake

##SBATCH --qos=INTR
##SBATCH --time=02:00:00
##SBATCH -A TISCHKOWITZ-SL3-CPU

## Modules section (required, do not remove)
. /etc/profile.d/modules.sh
module purge
module load rhel7/default-peta4

#Load modules for histograms
module load gcc-5.4.0-gcc-4.8.5-fis24gg
module load boost-1.63.0-gcc-5.4.0-lzswtlx
module load pandoc/2.0.6

## Set initial working folder
cd "${SLURM_SUBMIT_DIR}"

## Read parameters
sample="${1}"
job_file="${2}"
logs_folder="${3}"
scripts_folder="${4}"
pipeline_log="${5}"

## Report settings and run the job
echo ""
echo "Job name: ${SLURM_JOB_NAME}"
echo "Allocated node: $(hostname)"
echo ""
echo "Initial working folder:"
echo "${SLURM_SUBMIT_DIR}"
echo ""
echo "Sample: ${sample}"
echo ""
echo " ------------------ Output ------------------ "
echo ""

## Do the job
sample_log="${logs_folder}/s02_preprocess_and_gvcf_${sample}.log"
"${scripts_folder}/s02_preprocess_and_gvcf.sh" \
         "${sample}" \
         "${job_file}" \
         "${scripts_folder}" \
         "${pipeline_log}" &> "${sample_log}"
