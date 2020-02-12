use strict;
use Data::Dumper;
use Rob;
my $rob = new Rob;

my %w;
open(IN, "SRA_Metagenome_Types.tsv") || die "$! SRA_Metagenome_Types.tsv";
while (<IN>) {
	chomp;
	my @a=split /\t/;
	$w{$a[0]}=1 if ($a[1] eq "WGS");
}

close IN;

open(IN, "SRA_Metagenome_Sizes.tsv") || die "$! SRA_Metagenome_Sizes.tsv";
while (<IN>) {
	my @a=split /\t/;
	print if ($w{$a[0]});
}

