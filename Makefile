all: bowtie jellyfish sra-tools

bowtie:
	#cd tools/bowtie2-2.2.9 && $(MAKE)

jellyfish:
	#cd tools/jellyfish-2.2.6 && ./configure
	#cd tools/jellyfish-2.2.6 && $(MAKE)

sra-tools:
	#cd tools && tar xvfz ngs-1.2.5.tar.gz
	#cd tools/ngs-1.2.5/ngs-sdk && ./configure --prefix=$(PWD) --build-prefix=$(PWD) && $(MAKE) install
	#cd tools && tar xvfz ncbi-vdb-2.7.0.tar.gz
	#cd tools/ncbi-vdb-2.7.0 && ./configure --prefix=$(PWD) --build-prefix=$(PWD) --with-ngs-sdk-prefix=$(PWD) && $(MAKE) install
	#cd tools && tar xvfz sra-tools-2.7.0.tar.gz
	#cd tools/sra-tools-2.7.0 && ./configure --prefix=$(PWD) --with-ngs-sdk-prefix=$(PWD) --with-ncbi-vdb-sources=$(PWD)/tools/ncbi-vdb-2.7.0 --with-ncbi-vdb-build=$(PWD)/ncbi-vdb && $(MAKE) install
	
