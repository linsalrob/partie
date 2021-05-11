=pod

After using runs_to_abstracts.sh, we probably want to add the read counts per sample.

This will take two files: the output from runs_to_abstracts.sh and a file with tuples of [SRR ID\tcount]

It will append the mean, median, and stdev to the abstracts

=cut

use strict;
use Getopt::Std;
use Data::Dumper;
use Rob;
my $rob = new Rob;

my %opts;
getopts('a:c:o:v', \%opts);
unless ($opts{a} && $opts{c} && $opts{o}) {
	die <<EOF;
	$0
	-a runs_to_abstracts file that has [SRR ID\tTitle\tAbstract\tList of SRA IDs] (required)
	-c counts file that has [SRA ID\tCount] (required)
	-o output file (required)
	-v verbose output
EOF
}

open(IN, $opts{c}) || die "$! : $opts{c}";
if ($opts{v}) {print STDERR "Reading counts from $opts{c}\n"}
my %count;
while (<IN>) {
	chomp;
	my ($srr, $c)=split /\t/;
	$count{$srr}=$c;
}
close IN;
if ($opts{v}) {print STDERR "Averaging!\n"}
open(OUT, ">$opts{o}") || die "Can't write to $opts{o}";
print OUT "SRR\tTitle\tAbstract\tRuns\tMean abundance\tMedian abundance\tStdev\n";
open(IN, $opts{a}) || die "$! $opts{a}";
while (<IN>) {
	my @d;
	chomp;
	my $l = $_;
	my @a=split /\t/;
	my $sum;
	map {push @d, $count{$_}; $sum+=$count{$_}} split /,/, $a[3];
	if ($sum == 0) {
		print STDERR "ERROR: Got a total of 0 hits for $a[0] from |$l|\n";
		next;
	}
	if ($#d == 0) {
		print OUT join("\t", $_, $d[0], $d[0], 0), "\n";
	} else {
		print OUT join("\t", $_, $rob->mean(\@d), $rob->median(\@d), $rob->stdev(\@d)), "\n";
	}
}
close IN;
close OUT;

