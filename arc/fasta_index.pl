#!/usr/bin/env perl
use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;

use Bio::Index::Fasta;

=head1 Synopsis

  # create index
  fasta_db.pl --index <FILENAME>  [FASTA1 [FASTA2 ...]
  # fetch seqs
  cat ids.txt | fasta_db.pl --index <FILENAME> --ids -

=cut

my %opt = (
	'index' => 'index.idx',
	'ids' => undef,
);

GetOptions(\%opt, qw(index=s ids=s)) or die $!;

my $idx;

if(@ARGV){
	$idx = Bio::Index::Fasta->new(
		-filename => $opt{'index'},
		-write_flag => 1
	);
	$idx->make_index(@ARGV);
}else{
	$idx = Bio::Index::Fasta->new(
		-filename => $opt{'index'},
	); 
}

# fetch
if($opt{ids}){
	while(<STDIN>){
		chomp();
		print $idx->fetch($_);
	}
}

