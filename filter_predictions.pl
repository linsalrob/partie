#!/usr/bin/perl -w
#
# Filter the PARTIE annotations based on the size of the metagenome
# 
# We can not reliably predict small metagenomes, and so we have a cut off of 5,000,000 bp total for the metagenome in order to predict it. Below that we report not enough data.
# 
# The metagenome sizes file is automatically updated by epost during the processing steps.

use strict;

my $MINSIZE = 5000000; # minimum size for accurate classification

open(IN, "SRA_Metagenome_Sizes.tsv") || die "$! SRA_Metagenome_Sizes.tsv";
my %size;
while (<IN>) {
	chomp;
	my @line = split /\t/;
	$size{$line[0]} = $line[1];
}
close IN;

open(IN, "SRA_PARTIE_DATA.txt") || die "$! SRA_PARTIE_DATA.txt"; 
open(OUT, ">SRA_Metagenome_Types.tsv") || die "$! SRA_Metagenome_Types.tsv";
while (<IN>) {
	chomp;
	next if (/^RUN ID/);
	my @line = split /\t/;
	if (!defined $size{$line[0]}) {
		print STDERR "NO SIZE $line[0]\n";
		print OUT "$line[0]\tNO DATA\n";
		next;
	}
	if ($size{$line[0]} < $MINSIZE) {
		print OUT "$line[0]\tNOT ENOUGH DATA\n";
	} else {
		print OUT "$line[0]\t$line[5]\n";
	}
}
close IN;
close OUT;

