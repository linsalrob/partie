[![Edwards Lab](https://img.shields.io/badge/Bioinformatics-EdwardsLab-03A9F4)](https://edwards.sdsu.edu/research)
[![DOI](https://www.zenodo.org/badge/68630739.svg)](https://www.zenodo.org/badge/latestdoi/68630739)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


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
 * [SRA_PARTIE_DATA.txt](SRA_PARTIE_DATA.txt) is a tab separated file with the Partie data described above in case you want to generate your own classification. The columns of this data are ID, percent unique k-mer, percent 16S rRNA, percent phage, percent prokaryote, and partie annotation. 


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

# Size Restrictions

There is a minimum limit to how much data we need before we can accurately classify something. For example, we can't really classify a metagenome (or an amplicon library) that has [a single 150 bp read](https://www.ncbi.nlm.nih.gov/sra/?term=ERR1040181).

We are not exactly sure what the minimum limit is for accurate classification at the moment, we're trying to figure out what the minimum sequence depth is. However, our preliminary analysis suggests that we need about 5MB of sequence to get an accurate prediction. Below that, we're just not sure. So at the moment we filter sequences to only those that have 5,000,000 bp of sequence before we can create a prediction.

However, this may be a bit low and we should perhaps increase this, because [many, many datasets](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA348753) in the 5MB range are [reconstructed genomes](https://www.ncbi.nlm.nih.gov/sra/?term=SRR5326851) rather than metagenomes. But there are also [plenty of real metagenomes](https://www.ncbi.nlm.nih.gov/sra/?term=SRR2090082) that are that size. 

In a future release, we may train partie to try and recognize reconstructed genomes from metagenomes.

# MAGS

We have specifically labeled the 7,889 [metagenome assembled geomes](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA348753) from Phil Hugenholtz's study as MAGS. We will also add this label to other metagenome assembled genomes we identify.

# Zero restrictions

Tjere are several SRA datasets that have zero reads, zero bases, and zero data. We have several of those and we've denoted them as "NO DATA". There are a couple of explanations for these: either they have been deleted from the SRA for some reason (and probably replaced with something else), or they are protected by dbGAP or something similar. We're working on a solution for that.


# Databases

We have included the human database in PARTIE now. This is a pre-built bowtie2 index for [hg38.fa.gz](https://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/hg38.fa.gz) (md5sum: 1c9dcaddfa41027f17cd8f7a82c7293b) from UCSC. That is the human genome we use to compare everything to. We were undercounting the number of human matches in the database for a number of samples, and these are being (27 Jan 20) recounted, and we will update those numbers when completed.

