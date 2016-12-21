#!/usr/bin/env perl
use File::Basename;
use Getopt::Long qw(GetOptions);
use Data::Dumper;
use Cwd;


#---------------------------------------------
#---------------------------------------------
my $dir = getcwd;
local $ENV{PATH} = "$ENV{PATH}:$dir/bin";

$out = `which bowtie2`;
if($out_jellyfish =~ m/no bowtie2 in/){
	print "The executable for Bowtie2 not found on the path!\n";
	print "Either download and install your own version, or use the provided tools by typing:\n";
	print '    make tools';
	print "\n";
	exit();
}

$out = `which jellyfish`;
if($out =~ m/no jellyfish in/){
	print "The executable for Jellyfish not found on the path!\n";
	print "Either download and install your own version, or use the provided tools by typing:\n";
	print '    make tools';
	print "\n";
	exit();
}
$out = `which fastq-dump`;
if($out =~ m/no fastq-dump in/){
	print "The executable for fastq-dump not found on the path!\n";
	print "Either download and install your own version, or use the provided tools by typing:\n";
	print '    make tools';
	print "\n";
	exit();
}

#---------------------------------------------
#---------------------------------------------
my $count;
opendir(my $dh, "$dir/db") or die "opendir($dir.'/db'): $!";
while (my $de = readdir($dh)) {
	next unless $de =~ /\.bt2/;
	$count++;
}
closedir($dh);
if($count < 18){
	print "Databases not found!\n";
	print "You will need to type 'make'\n";
	exit();
}
#---------------------------------------------
#---------------------------------------------
#---define number of reads used
my $num_reads = 10000;
#---define kmer length
my $kmer_length = 15;
#---define how few kmers are in a rare kmer
my $rare_kmer = 10;

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
my ($filename, $path, $suffix) = fileparse($ARGV[0], @suffixes);

#---------------------------------------------
#--- INFILE HANDLING
#---------------------------------------------
if($suffix =~ m/\.sra/){
	my $out = `fastq-dump --fasta --split-spot --clip --skip-technical --readids --maxSpotId $num_reads  --stdout $ARGV[0] 2>&1 1> $filename.$num_reads.fna`;
	if($out =~ m/An error occurred/){
		my $out = `fastq-dump --fasta --split-spot --readids --maxSpotId 10000  --stdout $ARGV[0] 2>&1 1> $filename.$num_reads.fna`;
	}
}elsif($suffix =~ m/\.[fq|fastq|fasta|fa|fna]/){
	#system("./bin/seqtk seq -A $filename.fastx > $filename.$num_reads.fna");
	print "Error: fasta file\n";
	exit;
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
	print "\n";
	print "usage: ./partie.pl [options] READFILE\n";
	print "\n";
	print "Options: -nreads INT    the number of reads to pull sample from READFILE [10000]\n";
        print "         -klen   INT    the length of the kmers [15]\n";
        print "         -nrare  INT    maximum number a kmer can occur and still be considered rare [10]\n";
	exit();

}
