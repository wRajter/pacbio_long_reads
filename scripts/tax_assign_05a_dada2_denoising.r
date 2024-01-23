#!/usr/bin/env -S Rscript --vanilla


# Define the log file path
log_file_out <- ('log_file_out.log') # Update the path as needed

# Start logging for standard output
sink(log_file_out)

library(dada2)
library(openssl)

#############
# Variables #
#############

project <- Sys.getenv("PROJECT")
marker <- Sys.getenv("MARKER")
denoise_method <- 'dada2'
cores <- 4
band_size <- 32

####################
# Helper Functions #
####################

make_path <- function(...) {
  file.path(..., fsep = '/')
}

# Function to measure and print the duration
measure_duration <- function(start_time, end_time, step_name) {
  duration <- end_time - start_time
  cat(sprintf("Time taken for %s: %s\n", step_name, duration))
}


# dada_to_fasta (https://github.com/vmikk/metagMisc/blob/master/R/dada_to_fasta.R)
dada_to_fasta <- function(seqtab, out = "DADA2.fasta", hash = "sha1", ...){
  # prepare sequence names in USEARCH and VSEARCH-style
  seq_uniq <- dada2::getUniques(seqtab)   # integer vector named by unique sequence and valued by abundance.

  if(hash == "sha1"){ hh <- openssl::sha1(names(seq_uniq)) }
  if(hash == "sha256"){ hh <- openssl::sha256(names(seq_uniq)) }
  if(hash == "md5"){ hh <- openssl::md5(names(seq_uniq)) }

  seq_names <- paste(as.character(hh),
                     ";size=",
                     seq_uniq,
                     ";",
                     sep="")
  # Export sequence as fasta
  dada2::uniquesToFasta(seq_uniq, fout = out, ids = seq_names, ...)

  invisible(seq_names)
}

################
# Define paths #
################

results_path <- make_path('..', 'results')
raw_data_path <- make_path('..', 'raw_data')
path_filt_seq <- make_path(raw_data_path, 'dada2', project, marker, 'filtered')

sample_paths <- list.files(path = path_filt_seq, full.names = TRUE)

output_dir_path <- make_path(results_path, 'denoised', project, marker, denoise_method)


# Check if the output directory exists, if not create it
if (!dir.exists(output_dir_path)) {
  dir.create(output_dir_path, recursive = TRUE)
}

#############
# Denoising #
#############


for (sample_path in sample_paths) {

  sample_name = basename(sample_path)

  cat("Working on sample:", sample_name, "\n")

  # Start timer for dereplication
  start_time <- Sys.time()

  # Dereplicate
  drp2 <- derepFastq(sample_path, verbose=TRUE)

  # End timer for dereplication and print duration
  end_time <- Sys.time()
  measure_duration(start_time, end_time, "Dereplication")

  # Start timer for error learning
  start_time <- Sys.time()

  # Learn errors (https://rdrr.io/bioc/dada2/man/learnErrors.html)
  err2 <- learnErrors(drp2, errorEstimationFunction=PacBioErrfun, BAND_SIZE=band_size, multithread=TRUE)

  # End timer for error learning and print duration
  end_time <- Sys.time()
  measure_duration(start_time, end_time, "Error Learning")

  plotErrors(err2, nominalQ=TRUE)
  # How to read the plots:
  # The error rates for each possible transition (A→C, A→G, …) are shown in the plots.
  # Points are the observed error rates for each consensus quality score.
  # The black line shows the estimated error rates after convergence of the machine-learning algorithm.
  # The red line shows the error rates expected under the nominal definition of the Q-score.
  # So if the estimated error rates (black line) are a good fit to the observed rates (points), they overlap,
  # and the error rates should drop with increased quality.

  file.copy("Rplots.pdf", make_path(output_dir_path, paste0(sample_name, '_err_plot.pdf')))

  # Start timer for denoising
  start_time <- Sys.time()

  # Denoise
  dd2 <- dada(drp2, err=err2, BAND_SIZE=band_size, multithread=TRUE)

  saveRDS(dd2, file = make_path(output_dir_path, paste0(sample_name, '_err2.rds')))

  # End timer for denoising and print duration
  end_time <- Sys.time()
  measure_duration(start_time, end_time, "Denoising")

  # Creating sequence table from the dada-class object
  seqtab <- makeSequenceTable(dd2)

  # Write DADA sequences to fasta
  dada_to_fasta(seqtab, out = make_path(output_dir_path, paste0(sample_name, '_asv.fasta')), hash = "sha1")

  # Remember to close the logging
  sink()

  # Define new log file name and the directory to move it to
  new_log_name <- paste0('log_', sample_name,'_out.log')
  new_file_path <- file.path(output_dir_path, new_log_name)
  # Rename and move the file
  file.rename(log_file_out, new_file_path)

}
