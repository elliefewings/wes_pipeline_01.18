#!/bin/bash

## s01_hard_filter_vcf.sb.sh
## Wes library: hard filtering vcf by DP and QUAL
## SLURM submission script
## Ellie Fewings; 21Dec17

#SBATCH -J hard_filter
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mail-type=ALL
#SBATCH --no-requeue
#SBATCH -p skylake

##SBATCH --qos=INTR
##SBATCH --time=00:30:00
##SBATCH -A TISCHKOWITZ-SL3-CPU

## Modules section (required, do not remove)
. /etc/profile.d/modules.sh
module purge
module load rhel7/default-peta4 

# Additional modules for knitr-rmarkdown (used for histograms)
module load gcc/5.2.0
module load boost/1.50.0
module load texlive/2015
module load pandoc/1.15.2.1

#Add specific gmplib to path for histograms
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/rds/project/erf33/rds-erf33-medgen/tools/gmplib/lib

## Set initial working folder
cd "${SLURM_SUBMIT_DIR}"

## Report settings and run the job
echo ""
echo "Job name: ${SLURM_JOB_NAME}"
echo "Allocated node: $(hostname)"
echo ""
echo "Initial working folder:"
echo "${SLURM_SUBMIT_DIR}"
echo ""
echo " ------------------ Output ------------------ "
echo ""

## Read parameters
job_file="${1}"
scripts_folder="${2}"
log="${3}"

## Do the job
"${scripts_folder}/s01_hard_filter_vcf.sh" \
         "${job_file}" \
         "${scripts_folder}" &>> "${log}"
