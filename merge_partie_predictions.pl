#!/usr/bin/env perl
#


use strict;
use warnings;


=pod

As we generate new Partie data, we delete the libraries we are not 
interested in (i.e. Amplicon libraries), and so we don't reanalyze 
them. Therefore, we need to merge the new predictions and the old 
predictions.

=cut

use Getopt::Std;

my %opts;
getopts('p:n:', \%opts);
unless ($opts{'p'} && $opts{'n'}) {
	die <<EOF;
$0
-p existing partie file
-n new partie data
EOF
}


my %pred; # the predictions
my %data; # the data
open(IN, $opts{p}) || die "can't open $opts{p}";
while (<IN>) {
	chomp;
	my @a=split /\t/;
	$pred{$a[0]}=$a[5];
	$data{$a[0]}=\@a;
}
close IN;

open(IN, $opts{n}) || die "can't open $opts{n}";
while (<IN>) {
	next if (/^ID/);
	chomp;
	my @a=split /\t/;
	$a[0] =~ s/\.sra//;
	$a[0] =~ s/.partie//;
	# have we seen it and is the prediction the same
	next if ($pred{$a[0]} && $pred{$a[0]} eq $a[5]);
	if ($pred{$a[0]} && $pred{$a[0]} ne $a[5]) {
		print STDERR "Prediction for $a[0] switched from $pred{$a[0]} to $a[5]. We kept $a[5]\n";
	}
	$pred{$a[0]}=$a[5];
	$data{$a[0]}=\@a;
}

if (-e "SRA_Partie_Data.tsv") {
	print STDERR "SRA_Partie_Data.tsv backed up\n";
	system("mv -f SRA_Partie_Data.tsv SRA_Partie_Data.tsv.bak");
}


if (-e "SRA_Metagenome_Types.tsv") {
	print STDERR "SRA_Metagenome_Types.tsv backed up\n";
	system("mv -f SRA_Metagenome_Types.tsv SRA_Metagenome_Types.tsv.bak");
}

open(OUT,  ">SRA_Partie_Data.tsv") || die "$! SRA_Partie_Data.tsv";
foreach my $id (sort {$a cmp $b} keys %data) {
	print OUT join("\t", @{$data{$id}}), "\n";
}
close OUT;

open(OUT, ">SRA_Metagenome_Types.tsv") || die "SRA_Metagenome_Types.tsv";
foreach my $id (sort {$a cmp $b} keys %pred) {
	if (!defined $pred{$id}) {print STDERR "No prediction for $id\n"}
	print OUT join("\t", $id, $pred{$id}), "\n";
}
close OUT;

