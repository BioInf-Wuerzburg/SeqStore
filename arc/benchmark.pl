use warnings;
use strict;

use Benchmark qw(:all);
use FindBin qw($RealBin);

my $dir = '/home/dumps/projects/tr-guided/fasta_store/';
my $D_dir = $dir.'D/';
my $I_dir = $dir.'I/';
my $fasta = 'test.fa';
my $I_fasta = $I_dir.$fasta;
my $ids = $dir.'ids.txt';
my @ids;
my $I_idx = $I_dir."I.index";
my $D_idx = $D_dir."directory.index";

unless(-e $ids){
	open (FASTA, $dir.$fasta) or die "$!: $dir.$fasta";
	while(<FASTA>){
		push @ids, $1 if /^>(\S+)/;
	}
	open (IDS, '>', $ids) or die $!;
	print IDS $_,"\n" foreach @ids;
	close IDS;
}

# idx
#print "\n## Indexing ##################################\n";
#cmpthese(1, {
#	D_idx => sub{
#		unlink $D_dir;
#		qx($RealBin/fasta_db.pl --dir $D_dir);
#	},
#	I_idx => sub{
#		unlink $I_idx;
#		qx($RealBin/fasta_index.pl --index $I_idx $I_fasta);
#	},
#});

print "\n## Fetching ##################################\n";
print "ids: ", scalar @ids, "\n";


my $threads = 4;
timethese(10, {
	D_get_1 => sub{
		my $cmd = "\"cat $ids | $RealBin/fasta_db.pl --dir $D_dir --ids - >/dev/null\"\n";
		open (DX, "| xargs -n1 -P 1 bash -c") or die $!;
		print DX $cmd for (1..$threads);
		close DX;
	},
	I_get_1 => sub{
		my $cmd = "\"cat $ids | $RealBin/fasta_index.pl --index $I_idx --ids - >/dev/null\"\n";
		open (IX, "| xargs -n1 -P 1 bash -c") or die $!;
		print IX $cmd for (1..$threads);
		close IX;
	},
	D_get_5 => sub{
		my $cmd = "\"cat $ids | $RealBin/fasta_db.pl --dir $D_dir --ids - >/dev/null\"\n";
		open (DX, "| xargs -n1 -P 5 bash -c") or die $!;
		print DX $cmd for (1..$threads);
		close DX;
	},
	I_get_5 => sub{
		my $cmd = "\"cat $ids | $RealBin/fasta_index.pl --index $I_idx --ids - >/dev/null\"\n";
		open (IX, "| xargs -n1 -P 5 bash -c") or die $!;
		print IX $cmd for (1..$threads);
		close IX;
	},
#	D_get_25 => sub{
#		my $cmd = "\"cat $ids | $RealBin/fasta_db.pl --dir $D_dir --ids - >/dev/null\"\n";
#		open (DX, "| xargs -n1 -P 25 bash -c") or die $!;
#		print DX $cmd for (1..$threads);
#		close DX;
#	},
#	I_get_25 => sub{
#		my $cmd = "\"cat $ids | $RealBin/fasta_index.pl --index $I_idx --ids - >/dev/null\"\n";
#		open (IX, "| xargs -n1 -P 25 bash -c") or die $!;
#		print IX $cmd for (1..$threads);
#		close IX;
#	}
});





