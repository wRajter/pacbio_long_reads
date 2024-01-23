#!/bin/bash

# Filtering chimeric sequences after OTU clustering using vsearch

# Variables
NCORES=6
PROJECT=$(echo $PROJECT)
MARKER=$(echo $MARKER)
RESULTS_DIR_PATH="../results"
echo "Please enter the denoise method (dada2 or RAD): "
read DENOISE_METHOD
echo "Please enter the clustering threshold used (e.g., 0.90)"
read THRESHOLD
# Add similarity treshold to the SIM variable
SIM="sim_${THRESHOLD#0.}"

# Input directory
CLUSTERED_DIR="${RESULTS_DIR_PATH}/clustered/${PROJECT}/${MARKER}/${DENOISE_METHOD}/${SIM}"
# Output directory
CHIM_FILT_DIR="${RESULTS_DIR_PATH}/chimera_filtered/${PROJECT}/${MARKER}/${DENOISE_METHOD}/${SIM}"




################################################
## CHIMERA FILTERING USING INDIVIDUAL SAMPLES ##
################################################


SAMPLES=$(ls ${CLUSTERED_DIR}/*.fasta | \
          awk -F '/' '{ print $NF }' | \
          awk -F '.' '{ print $1 }' | \
          awk -F '_' '{ print $1 "_" $2 }')


echo "Samples used:"
echo "$SAMPLES"


mkdir -p ${CHIM_FILT_DIR}/


for SAMPLE in ${SAMPLES}
do
  # Cleaning
  rm -f ${CHIM_FILT_DIR}/${SAMPLE}_otu.fasta
  # Chimera removal
  echo "De novo chimera filtering: sample ${SAMPLE}"
  vsearch --uchime_denovo ${CLUSTERED_DIR}/${SAMPLE}_otu.fasta \
          --threads ${NCORES} \
          --nonchimeras ${CHIM_FILT_DIR}/${SAMPLE}_otu.fasta
done
