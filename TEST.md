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

## Results

These are the numbers you should get out of partie for these examples.


Test data set | percent unique kmer | percent 16S | percent PHAGE | percent PROKARYOTE
--- | --- | --- | --- | ---
16S Test Sequences< | 90.8609271523179 | 100 | 0 | 80
phages Test | 99.9818247909851 | 0 | 100 | 50
prokaryote | 100 | 0 | 0 | 100
ERR696648 | 71.7163948268223 | 0.0300000000000011 | 0.0100000000000051 | 3.48999999999999
ERR162903 | 33.6436026285273 | 13.92 | 0.5 | 25.5

