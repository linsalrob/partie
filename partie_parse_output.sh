########################################################################################
##                                                                                    ##
## Finish the partie installation steps. This is the part that runs the random        ##
## forest and determines what data we have.                                           ##
##                                                                                    ##
## Also added a step to do the automatic git commits!                                 ##
##                                                                                    ##
##                                                                                    ##
##                                                                                    ##
## (c) 2018 Rob Edwards                                                               ##
##                                                                                    ##
##                                                                                    ##
########################################################################################

HOST=`hostname`
WD=$PWD

DATE=`date +%b_%Y`
cd $DATE/partie

# cat the header and the files in one go:
head -n 1 ~/partie/SRA_PARTIE_DATA.txt | sed -e 's/\s\+PARTIE_Annotation//'  | cat - sge_out/* | grep -vP '0\t0\t0\t0' > partie_${DATE}.txt

# run the classification
Rscript ~/partie/RandomForest/PARTIE_Classification.R partie_${DATE}.txt

# combine the results with the previous results
perl -npe 's/\.sra//; s/"//g; s/\,/\t/g; ' partie_classification.csv | grep -v PARTIE_Annotation >> ~/partie/SRA_PARTIE_DATA.txt

cd ~/partie/
# creat the last file
cut -f 1,6 SRA_PARTIE_DATA.txt > SRA_Metagenome_Types.txt

git commit -m 'Updatine PARTIE data' -a; git push

cd $WD
