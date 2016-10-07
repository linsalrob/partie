export PATH := $(PATH):$(PWD)/bin

databases:
	curl -LO http://edwards.sdsu.edu/~katelyn/db.tar.gz
	tar xvfz db.tar.gz
	bowtie2-build db/16SMicrobial.fna db/16SMicrobial
	bowtie2-build db/phages.fna db/phages
	bowtie2-build db/prokaryotes.fna db/prokaryotes

all: databases bowtie jellyfish sra-tools

tools: bowtie jellyfish sra-tools

bowtie:
	cd tools && tar xvfz bowtie2-2.2.9.tar.gz
	cd tools/bowtie2-2.2.9 && $(MAKE)
	mkdir -p $(PWD)/bin
	cp tools/bowtie2-2.2.9/bowtie2* $(PWD)/bin

jellyfish:
	cd tools && tar xvfz jellyfish-2.2.6.tar.gz
	cd tools/jellyfish-2.2.6 && ./configure --prefix=$(PWD)
	cd tools/jellyfish-2.2.6 && $(MAKE) install

sra-tools:
	cd tools && tar xvfz ngs-1.2.5.tar.gz
	cd tools/ngs-1.2.5/ngs-sdk && ./configure --prefix=$(PWD) --build-prefix=$(PWD) && $(MAKE) install
	cd tools && tar xvfz ncbi-vdb-2.7.0.tar.gz
	cd tools/ncbi-vdb-2.7.0 && ./configure --prefix=$(PWD) --build-prefix=$(PWD) --with-ngs-sdk-prefix=$(PWD) && $(MAKE) install
	cd tools && tar xvfz sra-tools-2.7.0.tar.gz
	cd tools/sra-tools-2.7.0 && ./configure --prefix=$(PWD) --with-ngs-sdk-prefix=$(PWD) --with-ncbi-vdb-sources=$(PWD)/tools/ncbi-vdb-2.7.0 --with-ncbi-vdb-build=$(PWD)/ncbi-vdb && $(MAKE) install
seqtk:
	cd tools && tar xvfz seqtk-1.2.95.tar.gz
	cd tools/seqtk-1.2.95 && $(MAKE)
	cp tools/seqtk-1.2.95/seqtk $(PWD)/bin 
		
