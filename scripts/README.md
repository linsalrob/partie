# Accessory Scripts

These are some accessory scripts to help with generating and analyzing partie data.

They are provided as-is and you use at your own risk.

## partie_download.sh

This script will retrieve the latest SRA metadata SQL database from  AWS and parse it to suggest potential metagenome datasets. It will then try and submit a job to the cluster that downloads the data and runs partie on it.

Please note that this is designed to run on my cluster, and is not generalized code. You will need to edit the part where we submit everything to the cluster.

## partie_parse_output.sh

This parses the output from partie_download.sh and automatically updates this git repository with new IDs.

## runs_to_abstracts.sh

This takes a list of run ids and combines them based on their project identifiers. It then generates a tab separated file of:
   - SRP project identifier
   - Project title
   - Project abstract
   - List of runs associated with that project, separated by commas

## add_read_counts_to_abstracts.pl

This takes the output from `runs_to_abstracts.sh` above, and a file that has SRA IDs and counts, and adds the mean, median, and stdev for the counts to each project based on the runs that make up that project.
