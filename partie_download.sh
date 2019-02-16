########################################################################################
##                                                                                    ##
## Automatically download and extract all the SRA data. This self contained           ##
## bash script, should (!!) download a new version of the data and figure out         ##
## which are metagenomes.                                                             ##
##                                                                                    ##
## Note that this is designed to run on my cluster that uses SGE for job submission   ##
## if you run it elsewhere you will need to change the qsub part most likely.         ##
##                                                                                    ##
## (c) 2018 Rob Edwards                                                               ##
##                                                                                    ##
########################################################################################

HOST=`hostname`
DATE=`date +%b_%Y`
WD=$PWD

if [ -e $DATE ]; then
	echo "$DATE already exists. Do we need to do anything?"
	exit;
fi

mkdir $DATE
cd $DATE

# get the modification time
curl --head https://s3.amazonaws.com/starbuck1/sradb/SRAmetadb.sqlite.gz > timestamp.txt
grep Last-Modified timestamp.txt | sed -e 's/Last-Modified: //' > ~/GitHubs/partie/SRA_Update_Time

curl -Lo SRA_Accessions.tab ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab


# Download one of the SRA SQLite databases:
echo "Downloading and extracting the new SQL Lite data base"
curl -Lo SRAmetadb.sqlite.gz "https://s3.amazonaws.com/starbuck1/sradb/SRAmetadb.sqlite.gz"
if [ ! -e SRAmetadb.sqlite.gz ]; then
	echo "ERROR: No database was downloaded"
	exit -1
fi
echo "Uncompressing the gzip file";
gunzip SRAmetadb.sqlite.gz


# Get all the possible SRA metagenome samples from the SQL lite table. This is described at https://edwards.sdsu.edu/research/sra-metagenomes/
echo "Running the SQLite commands";
sqlite3 SRAmetadb.sqlite 'select run_accession from run where experiment_accession in (select experiment_accession from experiment where (experiment.library_strategy = "AMPLICON" or experiment.library_selection = "PCR"))' > amplicons.ids
sqlite3 SRAmetadb.sqlite 'select run_accession from run where experiment_accession in (select experiment_accession from experiment where experiment.library_source = "METAGENOMIC")' > source_metagenomic.ids
sqlite3 SRAmetadb.sqlite 'select run_accession from run where experiment_accession in (select experiment_accession from experiment where experiment.study_accession in (select study_accession from study where study_type = "Metagenomics"));' > study_metagenomics.ids
sqlite3 SRAmetadb.sqlite 'select run_accession from run where experiment_accession in (select experiment_accession from experiment where experiment.sample_accession in (select sample.sample_accession from sample where (sample.scientific_name like "%microbiom%" OR sample.scientific_name like "%metagenom%")))' > sci_name_metagenome.ids
grep -F -x -v -f amplicons.ids source_metagenomic.ids > source_metagenomic.notamplicons.ids
grep -F -x -v -f amplicons.ids study_metagenomics.ids > study_metagenomics.notamplicons.ids
grep -F -x -v -f amplicons.ids sci_name_metagenome.ids > sci_name_metagenome.notamplicons.ids
sort -u sci_name_metagenome.notamplicons.ids source_metagenomic.notamplicons.ids study_metagenomics.notamplicons.ids > SRA-metagenomes.txt

# look at the previously downloaded metagenomes
echo "Figuring out the new metagenomes to download"
cut -f 1 ~/GitHubs/partie/SRA_Metagenome_Types.tsv | grep -Fxvf - SRA-metagenomes.txt > SRA-metagenomes-ToDownload.txt

# now set up a cluster job to parse out some data
mkdir partie
cp SRA-metagenomes-ToDownload.txt partie/
cd partie

# how many jobs do we have?
COUNT=$(wc -l SRA-metagenomes-ToDownload.txt | awk '{print $1}')

# Note that I added zotkill.pl here to reduce a problem where sge was overwriting itself.
# See http://moo.nac.uci.edu/~hjm/zotkill.pl for more information about zotkill.pl
echo -e "SRA=\$(head -n \$SGE_TASK_ID SRA-metagenomes-ToDownload.txt | tail -n 1);\nperl \$HOME/partie/partie.pl -noheader \${SRA}.sra | $HOME/bin/zotkill.pl partie.out;" > partie.sh
# and submit a few jobs to the queue to test
# NOTE:
# Do not make the outputs a directory!!
# If you use a file for STDERR/STDOUT then you don't need to concatenate the outputs in the next step

# this deals with an error in the BASH_FUNC_module
unset module

if [ $HOST == "anthill" ]; then 
	# we can submit directly
	echo "submitting the partie job"
	qsub -V -cwd -t 1-$COUNT:1  -o sge_out -e sge_err ./partie.sh
else 
	# submit via ssh
	WD=$PWD
	echo "Running the partie command on anthill"
	ssh anthill "unset func; cd $WD; qsub -V -cwd -t 1-$COUNT:1  -o sge_out -e sge_err ./partie.sh"
fi

# get the sizes of the metagenomes
IDX=0;
while [ $IDX -lt $COUNT ]; do
	IDX=$((IDX+250));
	echo "Getting the sizes of the metagenomes upto number $IDX of $COUNT"; 
	head -n $IDX SRA-metagenomes-ToDownload.txt | tail -n 250 > temp;
	epost -db sra -input temp -format acc | esummary -format runinfo -mode xml | xtract -pattern Row -element Run,bases,spots,spots_with_mates,avgLength,size_MB >> SRA_Metagenome_Sizes.tsv;
done
rm -f temp

sort -u SRA_Metagenome_Sizes.tsv >> ~/GitHubs/partie/SRA_Metagenome_Sizes.tsv


echo "We have submitted the PARTIE jobs to the cluster, and you need to let them run."
echo "Once they are run (which doesn't take that long), you should be able to use the script:"
echo "partie_parse_output.sh"
echo "to finalize the data and add everything to GitHub"
