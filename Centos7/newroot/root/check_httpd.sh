#!/usr/bin/perl
my $tainted = 0;

my $wget_cmd = '/bin/ps aux';

open (IN, '-|', $wget_cmd)
	or die ("Can't ps");

   while (!eof(IN)) {
	my $q = readline (*IN);
#print $q."\n";		

	if ($q =~ /\/httpd/) {
		$tainted = 1;
	}
   }
close (IN);


unless ($tainted) {

my $wget_cmd = "/usr/local/apache2/bin/apachectl start";
system($wget_cmd);
system('date >> httpd_resets');
};

system("/root/check_apo.sh");
exit;
