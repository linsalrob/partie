

indexes:
	echo "Downloading the indexed databases from edwards.sdsu.edu"
	# curl -LO http://edwards.sdsu.edu/PARTIE/16SMicrobial.bowtie2indices.bz2
	curl --location --output 16SMicrobial.bowtie2indices.bz2 https://cloudstor.aarnet.edu.au/plus/s/633WsPy4qA9AzBf/download
	# curl -LO http://edwards.sdsu.edu/PARTIE/phage.bowtie2indices.bz2
	curl --location --output phage.bowtie2indices.bz2 https://cloudstor.aarnet.edu.au/plus/s/AdLl6oDffy4BkWo
	# curl -LO http://edwards.sdsu.edu/PARTIE/prokaryotes.bowtie2indices.bz2
	curl --location --output prokaryotes.bowtie2indices.bz2 https://cloudstor.aarnet.edu.au/plus/s/PUoT1BbjNzS1srn
	# curl -LO http://edwards.sdsu.edu/PARTIE/humanGenome.bowtie2indices.bz2
	curl --location --output humanGenome.bowtie2indices.bz2 https://cloudstor.aarnet.edu.au/plus/s/urSWL5vHHhMqMQX
	echo "Extracting the databases"
	tar vxf 16SMicrobial.bowtie2indices.bz2
	tar vxf phage.bowtie2indices.bz2
	tar vxf prokaryotes.bowtie2indices.bz2
	tar vxf humanGenome.bowtie2indices.bz2

databases:
	# curl -LO http://edwards.sdsu.edu/PARTIE/partiedb.tar.bz2
	curl --location --output partiedb.tar.bz2 https://cloudstor.aarnet.edu.au/plus/s/X3iaKphgfQXA81G
	tar vxk partiedb.tar.bz2
	bowtie2-build 16SMicrobial.fna 16SMicrobial
	bowtie2-build phages.fna phages
	bowtie2-build prokaryotes.fna prokaryotes
	bowtie2-build hg38.fa humanGenome


all: indexes

