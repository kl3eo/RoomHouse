#!/usr/bin/perl

my $RES=`/bin/sensors 2>&1 | awk '{print $1}'`;

my @chunks = split('\n',$RES);

my @chu = split(' ',$chunks[0]);

if ($chu[0] eq  "sh:" || $chu[0] eq  "No") {
	my $r = `rm -f /etc/sysconfig/sensors`;
}

exit;
