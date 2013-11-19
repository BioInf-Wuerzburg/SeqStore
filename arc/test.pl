open (BASH, '| bash test.sh');
print BASH "stream\n";
print "popel\n";
print BASH "more stream\n";
close BASH;
print "Perl\n";