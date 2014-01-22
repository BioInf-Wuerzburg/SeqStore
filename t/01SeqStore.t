#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

use FindBin qw($RealBin);
use lib "$RealBin/../lib/";

use Carp;
use Log::Log4perl qw(:easy :levels);
Log::Log4perl->init(\q(
	log4perl.rootLogger					= DEBUG, Screen
	log4perl.appender.Screen			= Log::Log4perl::Appender::Screen
	log4perl.appender.Screen.stderr		= 1
	log4perl.appender.Screen.layout		= PatternLayout
	log4perl.appender.Screen.layout.ConversionPattern = [%d{MM-dd HH:mm:ss}] [%C] %m%n
));

#--------------------------------------------------------------------------#
=head2 load module

=cut

BEGIN { use_ok('SeqStore'); }

my $class = 'SeqStore';

#--------------------------------------------------------------------------#
=head2 sample data

=cut


# create data file names from name of this <file>.t
(my $Fa_file = $FindBin::RealScript) =~ s/t$/fa/; # data
(my $Dmp_file = $FindBin::RealScript) =~ s/t$/dmp/; # data structure dumped
(my $Ids_file = $FindBin::RealScript) =~ s/t$/ids/; # data structure dumped

# eval <file>.dump
my %Dmp;
@Dmp{qw(
	ids
)} = do "$Dmp_file"; # read and eval the dumped structure

# slurp data to string
my @Fa = split(/(?<=\n)(?=>)/, do { local $/; local @ARGV = $Fa_file; <> });

#--------------------------------------------------------------------------#
=head2 Modulino _Main

=cut

subtest '_Main' => sub{
	can_ok($class, '_Main');
};

my $self;
subtest "$class->new" => sub{
	$self = new_ok($class, [
		path => $RealBin
	]);
};


subtest "Accessors" => sub{
	foreach my $acc (qw( path glob db out_fh ids_fh reindex ids)){
		can_ok($self, $acc);
		my $v = $self->$acc;
		my $v2 = "hmlgr";
		is($self->$acc($v2), $v2, '$o->'."$acc set");
		is($self->$acc(), $v2, '$o->'."$acc get");
		$self->{$acc} = undef unless defined $v; # manual reset for undef
		is($self->$acc($v), $v, '$o->'."$acc reset");
	}
};

subtest '$o->fetch' => sub{
	can_ok($self, "fetch");
	
	# fetch from array
	my @seqs = $self->fetch(ids => [@{$Dmp{ids}}[4,3]]);
	is("$seqs[0]", $Fa[4], '$o->'."fetch seq");
	is("$seqs[1]", $Fa[3], '$o->'."fetch another seq");
	
	# fetch from handle
	open(IDS, $Ids_file) or carp $!;
	@seqs = $self->fetch(ids_fh => \*IDS);
	is("$seqs[0]", $Fa[0], '$o->'."fetch ids from file");
	close IDS;

	# fetch FROM,TO array
	my $id = ${$Dmp{ids}}[0];
	my ($seq) = $self->fetch(ids => [[$id, 5,10]]);
	is($seq->seq, Fasta::Seq->new($Fa[0])->substr_seq(4,6)->seq, '$o->'."fetch seq ID,FROM,TO");
	
	# fetch FROM,TO handle
	open(ID, '<', \($id." 5 10")) or carp $!;
	($seq) = $self->fetch(ids_fh => \*ID);
	is($seq->seq, Fasta::Seq->new($Fa[0])->substr_seq(4,6)->seq, '$o->'."fetch seq ID FROM TO file");
	close ID;

	# fetch with converter
	$self->converter(sub{
		$_[0]->id("Hi_there");
	});
	my @converted_seqs = $self->fetch(ids => [@{$Dmp{ids}}[4,3]]);
	is("$converted_seqs[0]", $Fa[5], '$o->'."fetch seq with converter");
	
	
	
};


done_testing();	
__END__


















