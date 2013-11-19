#!/usr/bin/env perl
use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;

use Bio::DB::Fasta;

=head1 Synopsis

  cat ids.txt | fasta_db.pl --dir '/path/to/fastas/'

=cut

my %opt = (
	'ids' => undef,
);

GetOptions(\%opt, qw(dir=s ids=s)) or die $!;

my $db = Bio::DB::Fasta->new($opt{dir});

# D fetch
if($opt{ids}){
	while(<STDIN>){
		chomp();
		print $db->seq($_);
	}
}

