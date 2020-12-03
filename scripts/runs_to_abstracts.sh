# A script to convert a list of SRR IDs to a tsv file with study id, study title, study abstract, and study run ids

# check for the input and output file names

if [ ! -n "$1" ] || [ ! -n "$2" ]
then
	echo "Usage: `basename $0` <INPUT FILE OF IDS> <OUTPUT FILE OF ABSTRACTS>"
	exit $E_BADARGS
fi



INPUTFILE=$1
OUTPUTFILE=$2
TMPFILE=temp.txt

# we expect to find SRAmetadb.sqlite in the location $SRADB
SRADB=Dec_2020

echo "Currently using $SRADB/SRAmetadb.sqlite as the database"

if [ ! -e "$SRADB/SRAmetadb.sqlite" ]; 
then
	echo "Can't find $SRADB/SRAmetadb.sqlite"
	exit $E_BADARGS
fi


for SRR in $(cut -f1 -d, $INPUTFILE | grep -v 'SRR ID' ); do  x=$(sqlite3 $SRADB/SRAmetadb.sqlite "select study.study_accession, study.study_title, study.study_abstract from study where study.study_accession in (select study_accession from experiment where experiment.experiment_accession in (select experiment_accession from run where run_accession = '$SRR'));" | sed -e 's/|$/\t /; s/||/\t \t/g; s/|/\t/g; s/\r//g; s/\n//g'); echo -e "$SRR\t$x"; done >  $TMPFILE

perl -ne 'chomp; @a=split /\t/; $s=shift @a; $t=join("\t", @a); push @{$d{$t}}, $s; END {foreach $t (keys %d) {print "$t\t", join(",", @{$d{$t}}), "\n"}}' $TMPFILE > $OUTPUTFILE

#rm -f $TMPFILE
