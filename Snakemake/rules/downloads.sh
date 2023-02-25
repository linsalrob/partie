########################################################################################
##                                                                                    ##
## DO NOT USE. THIS HAS BEEN MUNGED BADLY BY ROB                                      ##
##                                                                                    ##
##                                                                                    ##
##                                                                                    ##
########################################################################################

# NOTE WE SHOULD DO THIS ONCE WE ARE COMPLETE
grep Last-Modified timestamp.txt | sed -e 's/Last-Modified: //' > ~/GitHubs/partie/SRA_Update_Time





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
	BEGIN=1; END=$((BEGIN+74999))
	while [[ $END -lt $COUNT ]]; do 
		echo $BEGIN $END; 
		qsub -V -cwd -t $BEGIN-$END:1  -o sge_out -e sge_err ./partie.sh
		echo "Submitting a partie job for sequences $BEGIN to $END"
		BEGIN=$((END+1)); 
		END=$((BEGIN+74999)); 
	done; 
	echo "Submitting a partie job for sequences $BEGIN to $END"
	qsub -V -cwd -t $BEGIN-$END:1  -o sge_out -e sge_err ./partie.sh

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
	epost -db sra -input temp -format acc | esummary -format runinfo -mode xml | xtract -pattern Row -element Run,bases,spots,spots_with_mates,avgLength,size_MB,ReleaseDate >> SRA_Metagenome_Sizes.tsv;
done
rm -f temp

sort -u SRA_Metagenome_Sizes.tsv >> ~/GitHubs/partie/SRA_Metagenome_Sizes.tsv


echo "We have submitted the PARTIE jobs to the cluster, and you need to let them run."
echo "Once they are run (which doesn't take that long), you should be able to use the script:"
echo "partie_parse_output.sh"
echo "to finalize the data and add everything to GitHub"
