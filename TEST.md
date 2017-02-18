# Testing PARTIE

Now that you have [installed](INSTALLATION.md) PARTIE you should run some tests on it.


Here are some examples for you to work with.

## Run partie with fasta or fastq files

```
perl partie.pl tests/16STest.fq 
perl partie.pl tests/16STest.fna 
perl partie.pl tests/phagesTest.fna 
perl partie.pl tests/phagesTest.fq  
perl partie.pl tests/prokaryote.fna 
perl partie.pl tests/prokaryote.fq
```

## Run partie with an SRA ID


```
perl partie.pl ERR696648.sra
perl partie.pl ERR162903.sra
```


## Run all the tests simultaneously

You can run all the tests and create a single output file. Notice that the noheader flag suppresses the output of the column labels. If you redirect this output to a file, you should get the same results as in tests/Example_partie_output.txt

```
perl partie.pl tests/16STest.fq
perl partie.pl -noheader tests/16STest.fna
perl partie.pl -noheader tests/phagesTest.fna
perl partie.pl -noheader tests/phagesTest.fq 
perl partie.pl -noheader tests/prokaryote.fna
perl partie.pl -noheader tests/prokaryote.fq
perl partie.pl -noheader ERR696648.sra
perl partie.pl -noheader ERR162903.sra
perl partie.pl -noheader SRR3939281.sra
```


## Results

These are the numbers you should get out of partie for these examples.


sample_name | percent_unique_kmer | percent_16S | percent_phage | percent_Prokaryote
--- | --- | --- | --- | ---
16STest.fq | 14.39| 100 | 0 | 100
16STest.fna | 14.39| 100 | 0 | 100
phagesTest.fna | 99.98| 0 | 100 | 50
phagesTest.fq | 99.98| 0 | 100 | 50
prokaryote.fna | 100 | 0 | 0 | 100
prokaryote.fq | 100 | 0 | 0 | 100
ERR696648.sra | 71.72 | 0.03 | 0.01 | 3.49
ERR162903.sra | 33.64 | 13.92 | 0.5 | 25.5
SRR3939281.sra | 88.88 | 0.33 | 0.89 | 1.39

# Classification

To use the classifier, you can run the Rscript:

```
Rscript RandomForest/PARTIE_Classification.R tests/Example_partie_output.txt
```

This will generate the following output:


 | percent_unique_kmer | percent_16S | percent_phage | percent_Prokaryote | PARTIE_Annotation
--- | --- | --- | --- | --- | ---
16STest.fq | 14.39 | 100 | 0 | 100 | AMPLICON
16STest.fna | 14.39 | 100 | 0 | 100 | AMPLICON
phagesTest.fna | 99.98 | 0 | 100 | 50 | OTHER
phagesTest.fq | 99.98 | 0 | 100 | 50 | OTHER
prokaryote.fna | 100 | 0 | 0 | 100 | WGS
prokaryote.fq | 100 | 0 | 0 | 100 | WGS
ERR696648.sra | 71.72 | 0.03 | 0.01 | 3.49 | WGS
ERR162903.sra | 33.64 | 13.92 | 0.5 | 25.5 | AMPLICON
SRR3939281.sra | 88.88 | 0.33 | 0.89 | 1.39 | WGS


Note the additional column that includes the PARTIE classification.
