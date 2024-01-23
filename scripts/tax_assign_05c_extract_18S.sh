#!/bin/bash

# Extracting the 18S rRNA region from the environmental sequences using cutadapt
# Extracted 18S will serve for taxonomic assignemnt

# Variables

PROJECT=$(echo $PROJECT)
MARKER=$(echo $MARKER)

# primers for extracting 18S from long fragments
F_PRIMER=$(echo $F_18S_PRIMER)
R_PRIMER=$(echo $R_18S_PRIMER)

echo "Please enter the denoise method (dada2 or RAD): "
read DENOISE_METHOD

IDENT_THRESHOLD=0.8 # minimum combined primer match identity threshold
RAW_DATA="../raw_data"
RESULTS_DIR_PATH="../results"
READS_DIR="${RAW_DATA}/${DENOISE_METHOD}/${PROJECT}/${MARKER}/filtered"

# Outpup directory
EXTRACTED_18S="${RESULTS_DIR_PATH}/denoised/${PROJECT}/extracted_18S/{$DENOISE_METHOD}"

# Reverse complement the reverse primer
R_PRIMER_RC=$(echo $R_PRIMER | rev | tr 'ATCGatcg' 'TAGCtagc')
echo "reverse complement of ${R_PRIMER} is ${R_PRIMER_RC}"

# Make output directory if it doesn't exist
mkdir -p ${EXTRACTED_18S}/


# Loop through all the fastq.gz files
for file in ${READS_DIR}/*.fastq.gz; do

  # Get sample name
  sample=$(echo $file | awk -F '/' '{ print $NF }' | awk -F '.' '{ print $1 }')
  echo "Sample: ${sample}"

  # Sanity check
  rm -f ${EXTRACTED_18S}/extracted_18S_${sample}.fasta \
        ${EXTRACTED_18S}/trimming_${sample}.log

  # Trim the sequences based on the primers
  cutadapt -a ${R_PRIMER_RC} \
           -g ${F_PRIMER} \
           -n 3 \
           -o ${EXTRACTED_18S}/extracted_18S_${sample}.fastq.gz \
              ${file} \
            > ${EXTRACTED_18S}/trimming_${sample}.log

done

OLD_MARKER=$(echo $MARKER)

export MARKER="extracted_18S"
echo IMPORTANT: Marker was set from $OLD_MARKER to $MARKER as you might work with the extracted 18S sequences.
echo If you want to set it to something else use the setenv.sh file.
