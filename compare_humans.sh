for SRR in $(cat humans.txt); do
	fastq-dump -N 5001 -X 105000 --outdir fastq --skip-technical  --readids --read-filter pass --dumpbase --clip $SRR;
	HITS=$(bowtie2 --no-head --no-unal -x humanGenome -U fastq/${SRR}_pass.fastq -p 16 | wc -l);
	SEQS=$(wc -l fastq/${SRR}_pass.fastq | awk '{print $1}' | sed -e 's/$/\/4/' | bc -l | sed -e 's/0\+$//' | sed -e 's/\.$//');
	echo -e "$SRR\t$SEQS\t$HITS";
	rm fastq/${SRR}_pass.fastq;
done
