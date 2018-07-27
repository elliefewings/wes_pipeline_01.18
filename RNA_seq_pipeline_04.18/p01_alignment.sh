#!/bin/bash

# p01_alignment.sh
# alignment of RNA-seq files
# Ellie Fewings, 27Apr18

#Running:
# p01_alignment.sh -d <dataset> -i <input location> -o <output location>


#Arguments
if [ $# -lt 1 ]; then
  echo "Not enough arguments"
  echo "RNA-seq alignment:"
  echo "p01_alignment.sh -d <dataset> -i <input location> -o <output location>"
        echo "-d dataset: The name of your dataset e.g. TCGA_onc_RNA"
        echo "-i input location: Location of source fastq files e.g. /analysis/mtgroup_share/users/ellie/source_fastq"
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
        echo "RNA-seq alignment:"
        echo "p01_alignment.sh -d <dataset> -i <input location> -o <output location>"
        echo "-d dataset: The name of your dataset e.g. TCGA_onc_RNA"
        echo "-i input location: Location of source fastq files e.g. /analysis/mtgroup_share/users/ellie/source_fastq"
        echo "-o output location: Location to store results e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/"
      exit 2
    ;;
  esac
done

if [[ "${dataset}" == "" || "${loc}" == "" || "${results}" == "" ]]; then
 echo "RNA-seq alignment:"
  echo "p01_alignment.sh -d <dataset> -i <input location> -o <output location>"
        echo "-d dataset: The name of your dataset e.g. TCGA_onc_RNA"
        echo "-i input location: Location of source fastq files e.g. /analysis/mtgroup_share/users/ellie/source_fastq"
        echo "-o output location: Location to store results e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/"
  exit 2
fi

#Set log and directories
set_dir="/home/$USER/mtgroup_share/users/$USER/RNA_seq_pipeline_04.18/${dataset}"
source_dir="${set_dir}/source_data"
aln_dir="${set_dir}/alignment"


#mkdir -p ${source_dir}

log="${set_dir}/${dataset}_RNA_seq_alignment.log"

#Start logging
echo "Started p01_alignment.sh: $(date +%d%b%Y_%H:%M:%S)" >> ${log}
echo "" >> ${log}
echo "Dataset: ${dataset}" >> ${log}
echo "" >> ${log}
echo "Location of source data: ${loc}" >> ${log}
echo "Location of results: ${results}/r01_alignment" >> ${log}

#Copy source data
echo "Started copying source data" >> ${log}
echo "" >> ${log}

cp ${loc}/* ${source_dir}/ >> ${log}

#Create samples.txt 

echo "Creating samples file" >> ${log}
echo "" >> ${log}

cd ${source_dir}
for sample in $(ls -1 *fastq.gz | sed 's/_r1.*//' | sed 's/_r2.*//' | sort -u ) ; do
  fq1="${sample}""_r1.fastq.gz"
  fq2="${sample}""_r2.fastq.gz"    
  echo "${sample}""	""${fq1}""	""${fq2}" > ${source_dir}/samples.txt
done

echo "Finished samples file" >> ${log}
echo "" >> ${log}
echo "Finished copying source data" >> ${log}
echo "" >> ${log}

#Align with tophat
echo "Started alignment $(date +%H:%M:%S)" >> ${log}
echo "" >> ${log}
while read sample r1 r2 ; do
  smp_dir="${set_dir}/alignment/${sample}"
  qc_dir="${smp_dir}/fastqc"
  mkdir -p ${qc_dir}
  echo "...Running fastqc on sample ${sample} $(date +%H:%M:%S)..." >> ${log}
  fastqc -o ${qc_dir} ${source_dir}/${r1} >> ${log}
  fastqc -o ${qc_dir} ${source_dir}/${r2} >> ${log}
  echo "...Aligning sample ${sample} $(date +%H:%M:%S)..." >> ${log}
  tophat2 -o ${smp_dir} -p 10 --no-coverage-search /data/Resources/References/hg19/hg19 ${source_dir}/${r1} ${source_dir}/${r2} &>> ${log}
done < ${source_dir}/samples.txt

echo "Finished alignment $(date +%H:%M:%S)" >> ${log}
echo "" >> ${log}

#Copy files and clean up
echo "Started copying results" >> ${log}
echo "" >> ${log}

mkdir -p "${results}/r01_alignment"
cp -r ${aln_dir}/* ${results}/r01_alignment/

echo "Finished copying results" >> ${log}
echo "" >> ${log}
echo "Finished p01_alignment.sh: $(date +%d%b%Y_%H:%M:%S)" >> ${log}


