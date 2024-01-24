#!/bin/bash

# If you want to set environment variables in your current shell session, you need to source the script (not executing it!)
# Therefore run it as `source setenv.sh` or `. setenv.sh`

export PROJECT="Suthaus_2023_test"
export MARKER="Full18S_test"

# primers for dada2 trimming - tax_assign_01a_dada2_trimming.r
export F_PRIMER="CTGGTTGATYCTGCCAGT" # F1
export R_PRIMER="TGATCCTTCTGCAGGTTCACCTAC" # EukBr

# primers for extracting 18S from long fragments
export F_18S_PRIMER="AACCTGGTTGATCCTGCCAG" # EukA
export R_18S_PRIMER="TACAAAGGGCAGGGACGTAAT" # 18S-SSU-1512-3P

# check primers used in primers.txt file


echo Project was set as: $PROJECT
echo Marker was set as: $MARKER
