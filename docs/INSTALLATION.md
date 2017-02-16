# Installing PARTIE

## Dependencies

PARTIE requires several tools to run and a database.

You will need to have the following software installed before you can run PARTIE

- bowtie2 [Available from sourceforge](https://sourceforge.net/projects/bowtie-bio/files/bowtie2/)
- jellyfish [Available from github](https://github.com/gmarcais/Jellyfish)
- seqtk [Available from github](https://github.com/lh3/seqtk)
- the NCBI SRA Toolkit. You should [download the prebuilt binaries](https://github.com/ncbi/sra-tools/wiki/Downloads)

Follow the installation instructions for each of those libraries.

## Databases

You will also need the databases that we have built. 

You can either use make to install them:

```
make databases
```

Or you can download them from [edwards.sdsu.edu](http://edwards.sdsu.edu/~katelyn/db.tar.gz) and then build them with bowtie2-build:

```
bowtie2-build db/16SMicrobial.fna db/16SMicrobial
bowtie2-build db/phages.fna db/phages
bowtie2-build db/prokaryotes.fna db/prokaryotes
```

## Using PARTIE

Once you have installed all the dependencies you should be able to run the test code
