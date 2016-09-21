#!/usr/bin/env perl
use File::Basename;
use Getopt::Long qw(GetOptions);
use Data::Dumper;
use Cwd;

my $dir = getcwd;
local $ENV{PATH} = "$ENV{PATH}:$dir/tools/bowtie2-2.2.9";
local $ENV{PATH} = "$ENV{PATH}:$dir/tools/jellyfish-2.2.6/bin";

print `jellyfish --version`;
exit;

#---define nuber of reads used
my $num_reads = 10000;
#---define kmer length
my $kmer_length = 15;
#---define how few kmers are in a rare kmer
my $rare_kmer = 10;

#---------------------------------------------
#---------------------------------------------
GetOptions ("nreads=i" => \$num_reads,
            "klen=i"   => \$kmer_length,
            "nrare=i"  => \$num_rare_kmer);

unless($ARGV[0]){
	&usage;
}
unless(-e $ARGV[0]){
	print "Error: filename does not exist\n";
	exit;
}
my @suffixes = qw(.sra .fastq .fq .fasta .fna .fa);
my ($filename, $path, $suffix) = fileparse("SRR925343.sra", @suffixes);

print $filename, " ", $suffix;
exit;
my $filename = basename($ARGV[0]);

#---FASTQ-DUMP
my $out = `./bin/fastq-dump --split-spot --clip --skip-technical --readids --maxSpotId $num_reads  --stdout $ARGV[0] 2>&1 1> $filename.fastx`;
if($out =~ m/An error occurred/){
	my $out = `./bin/fastq-dump --split-spot --readids --maxSpotId 10000  --stdout $ARGV[0] 2>&1 1> $filename.fastx`;
}
#---CONVERT TO FASTA
system("./bin/seqtk seq -A $filename.fastx > $filename.fna");
unlink("$filename.fastx");

#--COUNT HITS TO 16S
my $percent_16S = 0;
my $out = `./bin/bowtie2-2.2.4/bowtie2 -f -k 1 -x db/16S/16SMicrobial $filename.fna 2>&1 1> /dev/null | grep 'aligned 0 time'`;
if($out =~ m/\((\S+)%\)/){
	$percent_16S = 100-$1;
}
#---COUNT HITS TO PHAGES
my $percent_phage = 0;
my $out = `./bin/bowtie2-2.2.4/bowtie2 -f -k 1 -x db/phages/phages $filename.fna 2>&1 1> /dev/null | grep 'aligned 0 time'`;
if($out =~ m/\((\S+)%\)/){
	$percent_phage = 100-$1;
}
#---COUNT HITS TO PROKARYOTES
my $percent_prokaryote = 0;
my $out = `./bin/bowtie2-2.2.4/bowtie2 -f -k 1 -x db/prokaryotes/prokaryotes $filename.fna 2>&1 1> /dev/null | grep 'aligned 0 time'`;
if($out =~ m/\((\S+)%\)/){
	$percent_prokaryote = 100-$1;
}
#---COUNT UNIQUE KMERS
system("./bin/jellyfish count -m $kmer_length -s 100M -o $filename.jf $filename.fna");
unlink("$filename.fna");
system("./bin/jellyfish dump -c $filename.jf > $filename.txt");
unlink("$filename.jf");
my $total = 0;
my $count = 0;
open(INFILE, "$filename.txt");
while (<INFILE>) {
	chomp;
	my @line = split(/\s+/);
	$total += $line[1];
	if($line[1] < $rare_kmer){
		$count++;
	}
}
close(INFILE); 
unlink("$filename.txt");

#---OUPUT
print "percent unique kmer\t";
if($total){
	print ($count/$total);
}else{
	print "0";
}
print "\tpercent 16S\t";
print $percent_16S;
print "\tpercent PHAGE\t";
print $percent_phage;
print "\tpercent PROKARYOTE\t";
print $percent_prokaryote;
print "\n";


sub usage {
	print "\n";
	print "usage: ./partie.pl [options] READFILE\n";
	print "\n";
	print "Options: -nreads INT    the number of reads to pull sample from READFILE [10000]\n";
        print "         -klen   INT    the length of the kmers [15]\n";
        print "         -nrare  INT    maximum number a kmer can occur and still be considered rare [10]\n";
	exit();

}
