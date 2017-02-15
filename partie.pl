#!/usr/bin/env perl
use File::Basename;
use Getopt::Long qw(GetOptions);
use Data::Dumper;
use Cwd;
use strict;

#---------------------------------------------
#---define number of reads used
my $num_reads = 10000;
#---define kmer length
my $kmer_length = 15;
#---define how few kmers are in a rare kmer
my $rare_kmer = 10;

my $help; my $version; 

GetOptions ("nreads=i" => \$num_reads,
            "klen=i"   => \$kmer_length,
            "nrare=i"  => \$rare_kmer,
    	    "help"     => \$help,
            "version"  => \$version,
    );


if ($help) {
	&usage();
}

if ($version) {
	&version();
}

unless($ARGV[0]){
	&usage;
}
unless(-e $ARGV[0]){
	print "ERROR: READFILE filename was not provided\n\n";
	&usage;
	exit;
}


#---------------------------------------------
#---------------------------------------------
my $dir = getcwd;
local $ENV{PATH} = "$ENV{PATH}:$dir/bin";

my $out = `which bowtie2`;
if($out =~ m/no bowtie2 in/){
	print STDERR "The executable for bowtie2 was not found on the path!\n";
	print STDERR "Please download and install it as described in INSTALLATION.md\n";
	print STDERR "\n";
	exit();
}

$out = `which jellyfish`;
if($out =~ m/no jellyfish in/){
	print STDERR "The executable for Jellyfish was not found on the path!\n";
	print STDERR "Please download and install it as described in INSTALLATION.md\n";
	print STDERR "\n";
	exit();
}
$out = `which fastq-dump`;
if($out =~ m/no fastq-dump in/){
	print STDERR "The executable for fastq-dump was not found on the path!\n";
	print STDERR "Please download and install it as described in INSTALLATION.md\n";
	print STDERR "\n";
	exit();
}
$out = `which seqtk`;
if($out =~ m/no seqtk in/){
	print STDERR "The executable for seqtk was not found on the path!\n";
	print STDERR "Please download and install it as described in INSTALLATION.md\n";
	print STDERR "\n";
	exit();
}

#---------------------------------------------
# Check that we have some databases partie

if (!-e $dir."/db/") {
	print STDERR "Welcome to PARTIE\n";
	print STDERR "Please build the PARTIE databases by running the command\nmake\n";
	print STDERR "This will download the databases from our server and build them for you\n";
	print STDERR "Once you have run make, you should be able to use partie.pl to process your datasets\n";
	exit();
}

#---------------------------------------------
my $count;
opendir(my $dh, "$dir/db") or die "opendir($dir.'/db'): $!";
while (my $de = readdir($dh)) {
	next unless $de =~ /\.bt2/;
	$count++;
}
closedir($dh);
if($count < 18){
	print STDERR "Databases not found!\n";
	print STDERR "You will need to type 'make'\n";
	exit();
}
#---------------------------------------------




my @suffixes = qw(.sra .fastq .fq .fasta .fna .fa);
my ($filename, $path, $suffix) = fileparse($ARGV[0], @suffixes);

#---------------------------------------------
#--- INFILE HANDLING
#---------------------------------------------
if($suffix =~ m/\.sra/){
	my $out = `fastq-dump --fasta --read-filter pass --dumpbase --split-spot --clip --skip-technical --readids --maxSpotId $num_reads  --stdout $ARGV[0] 2>&1 1> $filename.$num_reads.fna`;
	if($out =~ m/An error occurred/){
		my $out = `fastq-dump --fasta ---read-filter pass --dumpbase -split-spot --readids --maxSpotId $num_reads --stdout $ARGV[0] 2>&1 1> $filename.$num_reads.fna`;
	}
}elsif($suffix =~ m/\.[fq|fastq|fasta|fa]/){
	system("./bin/seqtk seq -A $filename.fastx > $filename.$num_reads.fna");
}else{
	print "Error: unrecognized infile type\n";
}
#---------------------------------------------
#---------------------------------------------
#--CHECK DATABASES
my $out = `bowtie2-inspect -s db/16SMicrobial 2>&1 1> /dev/null`;
if($out){
	print "Error: 16S database corrupted\n";
	exit();
}
my $out = `bowtie2-inspect -s db/phages 2>&1 1> /dev/null`;
if($out){
	print "Error: phages database corrupted\n";
	exit();
}
my $out = `bowtie2-inspect -s db/prokaryotes 2>&1 1> /dev/null`;
if($out){
	print "Error: prokaryotes database corrupted\n";
	exit();
}

#--COUNT HITS TO 16S
my $percent_16S = 0;
my $out = `bowtie2 -f -k 1 -x db/16SMicrobial $filename.$num_reads.fna 2>&1 1> /dev/null | grep 'aligned 0 time'`;
if($out =~ m/\((\S+)%\)/){
	$percent_16S = 100-$1;
}
#---COUNT HITS TO PHAGES
my $percent_phage = 0;
my $out = `bowtie2 -f -k 1 -x db/phages $filename.$num_reads.fna 2>&1 1> /dev/null | grep 'aligned 0 time'`;
if($out =~ m/\((\S+)%\)/){
	$percent_phage = 100-$1;
}
#---COUNT HITS TO PROKARYOTES
my $percent_prokaryote = 0;
my $out = `bowtie2 -f -k 1 -x db/prokaryotes $filename.$num_reads.fna 2>&1 1> /dev/null | grep 'aligned 0 time'`;
if($out =~ m/\((\S+)%\)/){
	$percent_prokaryote = 100-$1;
}
#---COUNT UNIQUE KMERS
system("jellyfish count -m $kmer_length -s 100M -o $filename.$num_reads.jf $filename.$num_reads.fna");
unlink("$filename.$num_reads.fna");
system("jellyfish dump -c $filename.$num_reads.jf > $filename.$num_reads.txt");
unlink("$filename.$num_reads.jf");
my $total = 0;
my $count = 0;
open(INFILE, "$filename.$num_reads.txt");
while (<INFILE>) {
	chomp;
	my @line = split(/\s+/);
	$total += $line[1];
	if($line[1] < $rare_kmer){
		$count++;
	}
}
close(INFILE); 
unlink("$filename.$num_reads.txt");

#---OUPUT
print "percent unique kmer\t";
print "\tpercent 16S\t";
print "\tpercent PHAGE\t";
print "\tpercent PROKARYOTE\t";
print "\n";
if($total){
	print (($count/$total)*100);
}else{
      	print "0";
}
print "\t";
print $percent_16S;
print "\t";
print $percent_phage;
print "\t";
print $percent_prokaryote;
print "\n";


sub usage {
	
	print "\nWelcome to PARTIE.\n==================\n";
	if (! -e $dir."/db") {
		print "\nBefore you run PARTIE you need to run download and build the databases\n";
		print "You can easily do that by running the command\nmake\nin the terminal window. It will download what you need to make partie run\n";
		print "Once you have installed the databases, these are the commands you can use to run PARTIE:\n";
	}

print <<EOF;

usage: ./partie.pl [options] READFILE

Options:
	 -nreads INT    the number of reads to pull sample from READFILE [10000]
	 -klen   INT    the length of the kmers [15]
	 -nrare  INT    maximum number a kmer can occur and still be considered rare [10]\

	 -help          print this help menu
	 -version       print the current version

READFILE can either be a fastq or fasta file, or it can be an SRA ID but it must end .sra. 
If it is an SRA ID (ending .sra) we will use fastq-dump to download some of the sequences
from the NCBI SRA.

EOF

	exit();

}

sub version {
	open(IN, "VERSION") || die "Error. The VERSION file which should be a part of PARTIE is not present";
	my $ver = "Unknown";
	while (<IN>) {
		chomp;
		$ver = $_;
	}
	close IN;
	print "Version: $ver\n";
	print "\n";
	exit();
}
