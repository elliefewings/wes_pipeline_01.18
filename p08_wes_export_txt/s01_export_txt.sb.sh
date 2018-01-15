#!/bin/bash

## s01_export_txt.sb.sh
## Wes library: data export
## SLURM submission script
## Ellie Fewings; 21Dec17

#SBATCH -J export_data
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
module load gcc-5.4.0-gcc-4.8.5-fis24gg
module load boost-1.63.0-gcc-5.4.0-lzswtlx
module load texlive/2015
module load pandoc/2.0.6

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
"${scripts_folder}/s01_export_txt.sh" \
         "${job_file}" \
         "${scripts_folder}" &>> "${log}"
