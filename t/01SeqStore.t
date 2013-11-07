#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

use FindBin qw($RealBin);
use lib "$RealBin/../lib/";

use Carp;

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
	
	my @seqs = $self->fetch(ids => [@{$Dmp{ids}}[4,3]]);
	is("$seqs[0]", $Fa[4], '$o->'."fetch seq");
	is("$seqs[1]", $Fa[3], '$o->'."fetch another seq");
	
	open(IDS, $Ids_file) or carp $!;
	@seqs = $self->fetch(ids_fh => \*IDS, [@{$Dmp{ids}}[4,3]]);
	is("$seqs[0]", $Fa[0], '$o->'."fetch ids from file");
	close IDS;
	
};

done_testing();	
__END__


















