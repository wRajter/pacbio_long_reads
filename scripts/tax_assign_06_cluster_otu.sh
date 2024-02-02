#!/bin/bash


# Clustering of reads into OTUs using vsearch

# Variables
THREADS=6
RESULTS_DIR_PATH="../results"
PROJECT=$(echo $PROJECT)
MARKER=$(echo $MARKER)
echo "Please enter the denoise method (dada2 or RAD): "
read DENOISE_METHOD
echo "Please enter the clustering threshold (e.g., 0.90)"
read THRESHOLD
# Add similarity treshold to the SIM variable
SIM="sim_${THRESHOLD#0.}"


# input directory:
DENOISE_DIR="${RESULTS_DIR_PATH}/denoised/${PROJECT}/${MARKER}/${DENOISE_METHOD}"
# output directory:
CLUST_DIR="${RESULTS_DIR_PATH}/clustered/${PROJECT}/${MARKER}/${DENOISE_METHOD}/${SIM}"

###############################
## OTU CLUSTERING PER SAMPLE ##
###############################



# Create output directory
mkdir -p ${CLUST_DIR}

# Create variable containing all samples that we want to loop through
SAMPLES=$(ls ${DENOISE_DIR}/*.fasta | \
          awk -F '/' '{ print $NF }' | \
          awk -F '.' '{ print $1 }' | \
          awk -F '_' '{ print $1 "_" $2 }')


echo "Samples used:"
echo "$SAMPLES"


for SAMPLE in ${SAMPLES}
do

  # Cleaning
  rm -f ${CLUST_DIR}/${SAMPLE}_otu.fasta

  # Clustering
  VSEARCH_LOG="${CLUST_DIR}/${SAMPLE}_vsearch_log.txt"
  vsearch --cluster_fast ${DENOISE_DIR}/${SAMPLE}_asv.fasta \
          --id ${THRESHOLD} \
          --threads "${THREADS}" \
          --consout ${CLUST_DIR}/${SAMPLE}_otu.fasta \
          &> "${VSEARCH_LOG}"

done
