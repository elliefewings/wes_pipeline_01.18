#!/bin/bash

# p03_quant_cufflinks.sh
# Quantification and differential expression of RNA-seq files
# Ellie Fewings, 27Apr18

#Running:
# p03_quant_cufflinks.sh -d <dataset> -i <input location> -o <output location> -c [optional]<case control phenotypes>


#Arguments
if [ $# -lt 1 ]; then
  echo "Not enough arguments."
  echo "RNA-seq quantification:"
  echo "p03_quant_cufflinks.sh -d <dataset> -i <input location> -o <output location> -c [optional]<case control phenotypes>"
        echo "-d dataset: The name you want to give your set of bams e.g. TCGA_onc_RNA"
        echo "-i input location: Location of processed bam files e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/r02_processed_bams/"
        echo "-o output location: Location to store results e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/"
        echo "-c [optional] case control phenotypes: File containing binary of phenotypes to analyse in set. First column must contain sample name, second column 0/1 (0=control, 1=case) e.g. casecontrol.txt"
  exit 2
fi

while getopts ":d:i:o:c:" opt; do
  case $opt in
    d ) dataset="$OPTARG"
    ;;
    i ) loc="$OPTARG"
    ;;
    o ) results="$OPTARG"
    ;;
    c ) cases="$OPTARG"
    ;;
    * ) echo "Incorrect arguments"
        echo "RNA-seq quantification:"
        echo "p03_quant_cufflinks.sh -d <dataset> -i <input location> -o <output location> -c [optional]<case control phenotypes>"
        echo "-d dataset: The name you want to give your set of bams e.g. TCGA_onc_RNA"
        echo "-i input location: Location of processed bam files e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/r02_processed_bams/"
        echo "-o output location: Location to store results e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/"
        echo "-c [optional] case control phenotypes: File containing binary of phenotypes to analyse in set. First column must contain sample name, second column 0/1 (0=control, 1=case) e.g. casecontrol.txt"
      exit 2
    ;;
  esac
done

if [[ "${dataset}" == "" || "${loc}" == "" || "${results}" == "" ]]; then
 echo "RNA-seq quantification:"
  echo "p03_quant_cufflinks.sh -d <dataset> -i <input location> -o <output location> -c [optional]<case control phenotypes>"
        echo "-d dataset: The name you want to give your set of bams e.g. TCGA_onc_RNA"
        echo "-i input location: Location of processed bam files e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/r02_processed_bams/"
        echo "-o output location: Location to store results e.g. /analysis/mtgroup_share/users/ellie/TCGA_onc_RNA/"
        echo "-c [optional] case control phenotypes: File containing binary of phenotypes to analyse in set. First column must contain sample name, second column 0/1 (0=control, 1=case) e.g. casecontrol.txt"
  exit 2
fi

#Set log and directories
set_dir="/home/$USER/mtgroup_share/users/$USER/RNA_seq_pipeline_04.18/${dataset}"
proc_dir="${loc}"
source_dir="${set_dir}/source_data"
cl_dir="${set_dir}/r03_cufflinks"

mkdir -p ${cl_dir}

log="${set_dir}/${dataset}_RNA_seq_cufflinks.log"

#Start logging
echo "Started p03_quant_cufflinks.sh: $(date +%d%b%Y_%H:%M:%S)" >> ${log}
echo "" >> ${log}
echo "Dataset: ${dataset}" >> ${log}
echo "" >> ${log}
echo "Location of aligned bams: ${loc}" >> ${log}
echo "Location of results: ${results}/r02_removal_pcrdups" >> ${log}

#Quantification per sample
#echo "Started quantification and differential expression analysis $(date +%H:%M:%S)" >> ${log}
#echo "" >> ${log}
#while read sample r1 r2 ; do
#  smp_dir="${cl_dir}/${sample}"
#  mkdir ${smp_dir}
#  echo "...Analysing sample ${sample} $(date +%H:%M:%S)..." >> ${log}
  #Quantification
#  cufflinks -b /data/Resources/References/hg19/hg19.fa -u -p 10 -G /analysis/mtgroup_share/resources/bowtie_idx/Homo_sapiens.GRCh37.75.gtf -o ${smp_dir} ${proc_dir}/${sample}.AH.processed.bam
#done < ${source_dir}/samples.txt

#Differential expression
if [[ "${cases}" == "" ]]; then
  echo "No cases and controls set. Running differential expression across set..."
  cuffdiff -o ${cl_dir} -p 10 -b /data/Resources/References/hg19/hg19.fa -u /analysis/mtgroup_share/resources/bowtie_idx/Homo_sapiens.GRCh37.75.gtf ${proc_dir}/*.bam
else
  echo "Running differential expression across cases and controls..."   
  #Create lists cases and controls  
  casamp=""
  contamp=""
    
  #Set lists of cases and controls
  while read sample phen ; do
    if [[ "${phen}" == "1" ]]; then
      casamp="${casamp}${proc_dir}/${sample}.AH.processed.bam,"
    elif [[ "${phen}" == "0" ]]; then
      contamp="${casamp}${proc_dir}/${sample}.AH.processed.bam,"
    fi
  done < ${cases}
  
  #Count numbers of cases and controls
  (( case_n = ${#casamp} - 1 ))
  (( cont_n = ${#contamp} - 1 ))
  
  casamp=echo "${casamp}" | cut -c-${case_n}
  contamp=echo "${contamp}" | cut -c-${cont_n}
  
  #Print cases and controls to logs
  
  cuffdiff -o ${cl_dir} -p 10 -L cases,controls -b /data/Resources/References/hg19/hg19.fa -u /analysis/mtgroup_share/resources/bowtie_idx/Homo_sapiens.GRCh37.75.gtf ${casamp} ${contamp}

fi

echo "Finished quantification and differential expression analysis $(date +%H:%M:%S)" >> ${log}
echo "" >> ${log}


#Copy files and clean up
echo "Started copying results" >> ${log}
echo "" >> ${log}

mkdir -p "${results}/r03_cufflinks"
cp -r ${cl_dir}/* ${results}/r03_cufflinks/

echo "Finished copying results" >> ${log}
echo "" >> ${log}
echo "Finished p03_quant_cufflinks.sh: $(date +%d%b%Y_%H:%M:%S)" >> ${log}


