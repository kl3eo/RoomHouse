#!/usr/bin/perl
my $name  = $ARGV[0];

my @chunks = split('\.', $name);

my $res = '';
foreach my $c (@chunks) {
	$c = "0".$c if ($c < 10);
	$c = "0".$c if ($c < 100);
	$res .= $c.'.'
}

chop $res;

print $res;

exit;
