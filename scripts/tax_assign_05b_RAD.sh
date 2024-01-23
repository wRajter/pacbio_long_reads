#!/bin/bash

# Define project information
RAW_DATA="../raw_data"
SUFFIX=".fastq.gz"
JL_SCRIPT="julia/denoise_RAD.jl"



# Construct the reads directory path
READS_DIR="${RAW_DATA}/dada2/${PROJECT}/${MARKER}/filtered"


# Decompress all .gz files in the directory
echo "Decompressing all .gz files in ${READS_DIR}"
for file in ${READS_DIR}/*.gz; do
  gunzip -k ${file}
done

# Call my Julia script here
echo "Running Julia script"
julia ${JL_SCRIPT}


# Remove the decompressed files
echo "Compressing all .fastq files in ${READS_DIR}"
for file in ${READS_DIR}/*.fastq; do
  rm -f $file
done

echo "Done"
