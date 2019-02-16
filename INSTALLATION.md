# Installing PARTIE

## Dependencies

PARTIE requires several tools to run and a database.

You will need to have the following software installed before you can run PARTIE

- curl This should be already installed, if not you can [download it from here](https://curl.haxx.se/download.html)
- R and the randomForest library. Once you have R installed you can install that library with `install.packages(c("randomForest"), dependencies=TRUE);`
- bowtie2 [Available from sourceforge](https://sourceforge.net/projects/bowtie-bio/files/bowtie2/)
- jellyfish [Available from github](https://github.com/gmarcais/Jellyfish)
- seqtk [Available from github](https://github.com/lh3/seqtk)
- the NCBI SRA Toolkit. You should [download the prebuilt binaries](https://github.com/ncbi/sra-tools/wiki/Downloads) or check this [NCBI page for the latest versions](https://www.ncbi.nlm.nih.gov/sra/docs/toolkitsoft/)
- [zotkill](http://moo.nac.uci.edu/~hjm/zotkill.pl) is used to write to a single file. This is an elegant file locking approach to combine multiple outputs into one file, e.g. while running on a cluster

Follow the installation instructions for each of those libraries.

## Clone the code from GitHub

Once the libraries are installed you can clone the code base from GitHub:

```
git clone https://github.com/linsalrob/partie.git
```


## Databases

You will also need the databases that we have built. 

We provide the databases in two formats, and there are two ways you can install them.

### Formatted databases

This is probably the best download, you can download the three databases we use already formatted for bowtie2. These three databases should end up in the `db/` directory under PARTIE.


You can use make to install the files:

```
make indexes
```

Or you can download each of the three files separately (you don't need to do this if you did make):


- [16S](https://edwards.sdsu.edu/PARTIE/16SMicrobial.bowtie2indices.bz2) (Note that this file is 14M)
- [Phage](http://edwards.sdsu.edu/PARTIE/phage.bowtie2indices.bz2) (Note that this file is 225M)
- [Prokaryotes](http://edwards.sdsu.edu/PARTIE/prokaryotes.bowtie2indices.bz2) (Note that this file is 7.3G)

Once you have downloaded them you can extract them with:

```
tar xf 16SMicrobial.bowtie2indices.bz2
tar xf phage.bowtie2indices.bz2
tar xf prokaryotes.bowtie2indices.bz2
```


### Unformatted databases

You can download each of the databases as a single file, but then you will need to use bowtie2 to build them. Again, we have a Makefile for this, or you can do them manually:


To install this way using make

```
make databases
```

Or you can download them from [edwards.sdsu.edu](http://edwards.sdsu.edu/PARTIE/partiedb.tar.bz2) and then build them with bowtie2-build:

```
bowtie2-build db/16SMicrobial.fna db/16SMicrobial
bowtie2-build db/phages.fna db/phages
bowtie2-build db/prokaryotes.fna db/prokaryotes
```

## Using PARTIE

Once you have installed all the dependencies you should be able to run the [test code](TEST.md) for PARTIE.
