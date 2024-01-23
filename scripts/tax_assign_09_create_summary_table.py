# Imports
import os
import pandas as pd
import openpyxl


# Variables
project = os.getenv('PROJECT')
marker = os.getenv('MARKER')
denoise_method = input('Please enter the denoise method (dada2 or RAD): ')
sim_input = input('Please enter the clustering threshold used (e.g., 0.90): ')
sim = f"sim_{str(sim_input).lstrip('0.')}"
raw_data = os.path.join('..', 'raw_data')
results_dir_path = os.path.join('..', 'results')
blast_results = os.path.join(results_dir_path, 'tax_assignment_vsearch', project, marker, denoise_method, sim, 'blast')
output_path = os.path.join(results_dir_path, 'final_tables')


# Get paths
files = os.listdir(blast_results)
paths = [blast_results + '/' + file for file in files]

# Creating taxonomic table
record = {'otu_id': [],
          'size_denoised': [],
          'size_clustered': [],
          'kingdom': [],
          'domain': [],
          'phyllum': [],
          'class': [],
          'order': [],
          'family': [],
          'genus': [],
          'species': [],
          'closest_match': [],
          'percent_identity': [],
          'sample': []}

for path in paths:
    with open(path, 'rt') as f:
        lines = f.readlines()
        for line in lines:
            record['otu_id'].append(line.split('\t')[0])
            record['size_denoised'].append(line.split('\t')[0].split('size=')[-1].split(';')[0])
            record['size_clustered'].append(line.split('\t')[0].split('seqs=')[-1])
            tax_assign = line.split('\t')[1]
            record['kingdom'].append(tax_assign.split(',')[0].split(':')[1])
            record['domain'].append(tax_assign.split(',')[1].lstrip('d:'))
            record['phyllum'].append(tax_assign.split(',')[2].lstrip('p:'))
            record['class'].append(tax_assign.split(',')[3].lstrip('c:'))
            record['order'].append(tax_assign.split(',')[4].lstrip('o:'))
            record['family'].append(tax_assign.split(',')[5].lstrip('f:'))
            record['genus'].append(tax_assign.split(',')[6].lstrip('g:'))
            record['species'].append(tax_assign.split(',')[7].lstrip('s:'))
            record['closest_match'].append(line.split('\t')[1].split(';')[0].split('.')[0])
            record['percent_identity'].append(line.split('\t')[2])
            record['sample'].append(path.split('/')[-1].lstrip('blast6_').rstrip('.tab'))

sum_table = pd.DataFrame.from_dict(record)


# Create the output_path if it does not exist
if not os.path.exists(output_path):
    os.makedirs(output_path)

# Define file paths for the Excel and CSV tables
excel_file_path = f'{output_path}/summary_table_{project}_{marker}_{denoise_method}_{sim}.xlsx'
csv_file_path = f'{output_path}/summary_table_{project}_{marker}_{denoise_method}_{sim}.tsv'

# Save the summary table as an Excel table
sum_table.to_excel(excel_file_path)

# Notify the user about the Excel file
print(f"Summary table saved as Excel file: {excel_file_path}")

# Save the summary table as a TSV table
sum_table.to_csv(csv_file_path, sep='\t')

# Notify the user about the CSV file
print(f"Summary table saved as TSV file: {csv_file_path}")
