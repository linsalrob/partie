# PARTIE
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
 * [SRA_Partie_Data.tsv](SRA_Partie_Data.tsv) is a tab separated file with the Partie data described above in case you want to generate your own classification. The columns of this data are ID, percent unique k-mer, percent 16S rRNA, percent phage, percent prokaryote, and partie annotation. 


The file [SRA_Update_Time](SRA_Update_Time) shows the time of the last update of the SRA.

# Installation

Please see the [installation](INSTALLATION.md) page to find out about the prerequisites and to install the databases for PARTIE.

# Testing

Please see the [test suite](TEST.md) for PARTIE

# Running PARTIE

You can provide PARTIE with several different inputs. We use the extension to figure out what kind of input you have provided.

- fasta DNA sequence files (ending .fna, .fa, or .fasta)
- fastq DNA sequence files (ending .fq or .fastq)
- SRA run IDs. Append .sra to the end (e.g. DRR023185.sra)
- A text file with a list of SRA ids (ending .txt)


## Run partie with fasta or fastq files

```
perl partie.pl <fasta file>
perl partie.pl <fastq file>
```

## Run partie with an SRA ID


```
perl partie.pl SRAID.sra
```

For more examples, see the [testing](TEST.md) documentation.


# Classifying the data

We have provided a pre-built classifier, though if you would like to rebuild the classifier, you can run the training code. You should not need to do that though.

Once you have the output from partie, you can run the classifier:

```
Rscript RandomForest/PARTIE_Classification.R outputfile.txt
```

For more examples, see the [testing](TEST.md#classification) documentation.



