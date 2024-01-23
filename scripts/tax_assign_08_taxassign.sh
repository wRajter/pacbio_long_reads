#!/bin/bash

# Taxonomic assignment using vsearch

# Variables
THREADS=12
PROJECT=$(echo $PROJECT)
MARKER=$(echo $MARKER)
RESULTS_DIR_PATH="../results"
RAW_DATA="../raw_data"
DATABASE="${RAW_DATA}/reference_alignments/pr2_v5/pr2_version_5.0.0_SSU_UTAX_plus_vamp_2023.fasta"
SEQTK="${RAW_DATA}/packages/seqtk"
IDENTITY=0.6
echo "Please enter the denoise method (dada2 or RAD): "
read DENOISE_METHOD
echo "Please enter the clustering threshold used (e.g., 0.90)"
read THRESHOLD
# Add similarity treshold to the SIM variable
SIM="sim_${THRESHOLD#0.}"

# Input directory
CHIM_FILT_DIR="${RESULTS_DIR_PATH}/chimera_filtered/${PROJECT}/${MARKER}/${DENOISE_METHOD}/${SIM}"
# Output directory
ASSIGNMENT_DIR="${RESULTS_DIR_PATH}/tax_assignment_vsearch/${PROJECT}/${MARKER}/${CELL}/${DENOISE_METHOD}/${SIM}/blast"
VAMP_SEQ_DIR="${RESULTS_DIR_PATH}/tax_assignment_vsearch/${PROJECT}/${MARKER}/${CELL}/${DENOISE_METHOD}/${SIM}/vamp_specific"


################
## ASSIGNMENT ##
################


# samples
SAMPLES=$(ls ${CHIM_FILT_DIR}/*.fasta | \
          awk -F '/' '{ print $NF }' | \
          awk -F '.' '{ print $1 }' | \
          awk -F '_' '{ print $1 "_" $2 }')


echo "Samples used:"
echo "$SAMPLES"

mkdir -p ${ASSIGNMENT_DIR}/

# Taxonomic assignment analysis:

for SAMPLE in ${SAMPLES}
do
  echo -e "\n\n\n###### Working on sample: $SAMPLE ######"
  rm -f ${ASSIGNMENT_DIR}/blast6_${SAMPLE}.tab
  vsearch --usearch_global ${CHIM_FILT_DIR}/${SAMPLE}_otu.fasta \
         --dbmask none \
         --qmask none \
         --db ${DATABASE} \
         --id ${IDENTITY} \
         --iddef 3 \
         --blast6out ${ASSIGNMENT_DIR}/blast6_${SAMPLE}.tab
  echo -e "\nVampyrellids found:"
  grep 'Vamp' ${ASSIGNMENT_DIR}/blast6_${SAMPLE}.tab | wc -l
done


###############################
## PULLING OUT THE VAMP SEQS ##
###############################


mkdir -p ${VAMP_SEQ_DIR}

for SAMPLE in ${SAMPLES}
do
  rm -f ${ASSIGNMENT_DIR}/vamp_ids_${SAMPLE}.txt \
        ${VAMP_SEQ_DIR}/${SAMPLE}_otu.fasta

  grep 'Vampyrellida' ${ASSIGNMENT_DIR}/blast6_${SAMPLE}.tab | \
  awk '{print $1}' > \
  ${ASSIGNMENT_DIR}/vamp_ids_${SAMPLE}.txt

  ${SEQTK}/seqtk subseq \
    ${CHIM_FILT_DIR}/${SAMPLE}_otu.fasta \
    ${ASSIGNMENT_DIR}/vamp_ids_${SAMPLE}.txt > \
    ${VAMP_SEQ_DIR}/${SAMPLE}_otu.fasta

  rm -f ${ASSIGNMENT_DIR}/vamp_ids_${SAMPLE}.txt
done
