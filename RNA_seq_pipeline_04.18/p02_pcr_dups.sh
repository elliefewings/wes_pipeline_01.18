#!/bin/bash

# p02_pcr_dups.sh
# Processing of RNA-seq files
# Ellie Fewings, 27Apr18

#Running:
# p02_pcr_dups.sh -d <dataset> -i <input location> -o <output location>


#Arguments
if [ $# -lt 1 ]; then
  echo "Not enough arguments"
  echo "RNA-seq processing:"
  echo "p02_pcr_dups.sh -d <dataset> -i <input location> -o <output location>"
        echo "-d dataset: The name of your dataset e.g. TCGA_onc_RNA"
        echo "-i input location: Location of bam files e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/r01_alignment"
        echo "-o output location: Location to store results e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/"
  exit 2
fi

while getopts ":d:i:o:" opt; do
  case $opt in
    d ) dataset="$OPTARG"
    ;;
    i ) loc="$OPTARG"
    ;;
    o ) results="$OPTARG"
    ;;
    * ) echo "Incorrect arguments"
        echo "RNA-seq processing:"
        echo "p02_pcr_dups.sh -d <dataset> -i <input location> -o <output location>"
        echo "-d dataset: The name of your dataset e.g. TCGA_onc_RNA"
        echo "-i input location: Location of bam files e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/r01_alignment"
        echo "-o output location: Location to store results e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/"
      exit 2
    ;;
  esac
done

if [[ "${dataset}" == "" || "${loc}" == "" || "${results}" == "" ]]; then
        echo "RNA-seq processing:"
        echo "p02_pcr_dups.sh -d <dataset> -i <input location> -o <output location>"
        echo "-d dataset: The name of your dataset e.g. TCGA_onc_RNA"
        echo "-i input location: Location of bam files e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/r01_alignment"
        echo "-o output location: Location to store results e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/"
  exit 2
fi

#Set log and directories
set_dir="/home/$USER/mtgroup_share/users/$USER/RNA_seq_pipeline_04.18/${dataset}"
proc_dir="${set_dir}/r02_processed_bams"
qc_dir="${proc_dir}/QC"
source_dir="${set_dir}/source_data"

mkdir -p ${qc_dir}

log="${set_dir}/${dataset}_RNA_seq_removal_pcrdups.log"

#Create samples file
cd ${loc}
#ls -d1 */ | sed 's/\/$//' > ${loc}/samples.txt

#Start logging
echo "Started p02_pcr_dups.sh: $(date +%d%b%Y_%H:%M:%S)" >> ${log}
echo "" >> ${log}
echo "Dataset: ${dataset}" >> ${log}
echo "" >> ${log}
echo "Location of aligned bams: ${loc}" >> ${log}
echo "Location of results: ${results}/r02_removal_pcrdups" >> ${log}

#Sort, remove pcr dups and qc
echo "Started PCR duplicate removal $(date +%H:%M:%S)" >> ${log}
echo "" >> ${log}
while read sample r1 r2 ; do
  smp_dir="${loc}/${sample}"
  echo "...Processing sample ${sample} $(date +%H:%M:%S)..." >> ${log}
  #Sort bam
  samtools sort -o ${smp_dir}/${sample}.AH.sorted.bam ${smp_dir}/accepted_hits.bam >> ${log}
  #Remove PCR dups
  samtools rmdup ${smp_dir}/${sample}.AH.sorted.bam ${proc_dir}/${sample}.AH.processed.bam >> ${log}
  #fastqc
  fastqc -o ${qc_dir} ${proc_dir}/${sample}.AH.processed.bam >> ${log}
  #flagstat
  samtools flagstat ${smp_dir}/accepted_hits.bam > ${qc_dir}/${sample}.AH.flagstat >> ${log}
  samtools flagstat ${proc_dir}/${sample}.AH.processed.bam > ${qc_dir}/${sample}.AH.processed.flagstat >> ${log}
done < ${loc}/samples.txt

echo "Finished PCR duplicate removal $(date +%H:%M:%S)" >> ${log}
echo "" >> ${log}


#Copy files and clean up
echo "Started copying results" >> ${log}
echo "" >> ${log}

mkdir -p "${results}/r02_processed_bams"
cp -r ${proc_dir}/* ${results}/r02_processed_bams/

echo "Finished copying results" >> ${log}
echo "" >> ${log}
echo "Finished p02_pcr_dups.sh: $(date +%d%b%Y_%H:%M:%S)" >> ${log}


