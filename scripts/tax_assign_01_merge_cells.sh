#!/bin/bash


# Merging cell1 and cell2 reads fastq files into cell_combined file

# Variables
RAW_DATA="../raw_data"
FASTQ_DIR="${RAW_DATA}/pacbio_reads/${PROJECT}/${MARKER}"
OUTPUT="${FASTQ_DIR}/cell_combined"

# Save filenames to a variable
files=$(basename -a ${FASTQ_DIR}/cell1/*.fastq.gz)

# Cleaning
rm -r ${OUTPUT} 2>/dev/null
mkdir -p ${OUTPUT}


for file in ${files}
do
  file1="${FASTQ_DIR}/cell1/${file}"
  file2="${FASTQ_DIR}/cell2/${file}"

  if [ -e "$file1" ] && [ -e "$file2" ]; then
    cat $file1 $file2 > ${OUTPUT}/${file}
    echo "Successfully merged ${file} from cell1 and cell2 into cell_combined."
  else
    echo "Warning: Missing file in one of the cells for ${file}"
  fi
done
