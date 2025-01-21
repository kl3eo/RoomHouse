#!/usr/bin/perl

my $res = `grep -r "may be called on a closed session" /home/nobody/vchat/lastlog`;

if (length($res)) {
	print "Res length is ".length($res)."!\n";
	my $r = `/home/nobody/restart_maven.sh`;
}

exit;

