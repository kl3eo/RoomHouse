#!/bin/perl

use strict;

my $counter = 0;
my $flag = 0;
open (my $fh, '-|', '/usr/bin/v4l2-ctl --list-devices') or die $!;

while (my $q = <$fh>) {
	
	chomp($q);
	
	if ($q =~ /dev\/video/) {
		$flag = 1 if ($counter);
		++$counter;
	} else {
		 if (length($q)) {
		 	$flag = 0;
			$counter = 0;
		 }
	}
	
}

close ($fh);

print $flag;
exit;
