# partie
PARTIE is a program to partition sequence read archive (SRA) metagenomics data into amplicon and shotgun data sets. The user-supplied annotations of the data sets can not be trusted, and so PARTIE allows automatic separation of the data.

PARTIE takes a subsample of the data, measures several different parameters associated with the sequences, and uses those parameters to classify the sequences based on a trained random forest.

Currently, PARTIE classifies the data based on: 
 * percent_unique_kmer: The percent of the sequences are represented by unique _k_-mers
 * percent_16S: The percent of the sequences that are similar to 16S genes
 * percent_phage: The percent of the sequences that are similar to phage genes
 * percent_Prokaryote: The percent of the sequences that are similar to prokaryotic genes (those from Bacteria and Archaea).

We typically classify the data sets into three groups:
 * WGS: Random Community Metagenomes (including metatranscriptomes)
 * AMPLICON: 16S metabarcoding projects
 * OTHER: everything else

We have released two files:
 * [SRA_Metagenome_Types.tsv](SRA_Metagenome_Types.tsv) is a tab separated file with two columns, the SRA run ID and the classification of the sequence.
 * [SRA_Partie_Data.tsv](SRA_Partie_Data.tsv) is a tab separated file with the Partie data described above in case you want to generate your own classification


The current version of this data release contains 226,648 SRA data sets:
 * 45,867 WGS sequences
 * 173,452 AMPLICON sequences
 * 7,329 OTHER sequences


