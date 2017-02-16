export PATH := $(PATH):$(PWD)/bin


indexes:
	echo "Downloading the indexed databases from edwards.sdsu.edu"
	cd db
	curl -LO http://edwards.sdsu.edu/PARTIE/16SMicrobial.bowtie2indices.bz2
	curl -LO http://edwards.sdsu.edu/PARTIE/phage.bowtie2indices.bz2
	curl -LO http://edwards.sdsu.edu/PARTIE/prokaryotes.bowtie2indices.bz2
	echo "Extracting the databases"
	tar vxf 16SMicrobial.bowtie2indices.bz2
	tar vxf phage.bowtie2indices.bz2
	tar vxf prokaryotes.bowtie2indices.bz2

databases:
	curl -LO http://edwards.sdsu.edu/PARTIE/db.tar.gz
	tar xvfz db.tar.gz
	bowtie2-build db/16SMicrobial.fna db/16SMicrobial
	bowtie2-build db/phages.fna db/phages
	bowtie2-build db/prokaryotes.fna db/prokaryotes




all: indexes

