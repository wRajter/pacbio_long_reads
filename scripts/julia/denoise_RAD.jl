# tax_assign_denoise.jl

using Pkg

# Pkg.add(url="https://github.com/MurrellGroup/NextGenSeqUtils.jl")
# Pkg.add(url="https://github.com/MurrellGroup/DPMeansClustering.jl")
# Pkg.add(url="https://github.com/MurrellGroup/RobustAmpliconDenoising.jl")

# Load required packages
using NextGenSeqUtils, RobustAmpliconDenoising, CodecZlib

# Define project information
project = ENV["PROJECT"]
marker = ENV["MARKER"]
denoised_method = "RAD"
raw_data = joinpath("..", "raw_data")
results_path= joinpath("..", "results")
suffix = ".fastq"

# Construct the raw_reads_dir path
reads_dir = joinpath(raw_data, "dada2", project, marker, "filtered")

# Construct output path
output_path = joinpath(results_path, "denoised", project, marker, denoised_method)

# List files in the raw_reads_dir directory
files = [file for file in readdir(reads_dir) if endswith(file, suffix)]

# Check if the output directory exists, if not create it
if !isdir(output_path)
  mkpath(output_path)
end

# Loop through each sample and perform denoising
for file in files

  # Construct the file path for the current sample
  filt_seq_path = joinpath(reads_dir, file)

  sample_name = match(r"^(.*?)\.(.*)", file).captures[1]

  # Read and denoise the sequences
  seqs, QVs, seq_names = read_fastq(filt_seq_path)
  templates, template_sizes, template_indices = denoise(seqs)

  # Construct the save_fasta path for the denoised sequences
  save_fasta = joinpath(output_path, "asv_$sample_name" * ".fasta")

  # Write denoised sequences to a fasta file
  write_fasta(save_fasta, templates, names = ["seq$(j)_$(template_sizes[j])" for j in 1:length(template_sizes)])

  # Print a message indicating completion for the current sample
  println("Denoising for $sample_name done. Fasta file save to $save_fasta")

end
