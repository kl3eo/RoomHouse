#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;
print $query->header(-charset=>'koi8-r');

open (IN, '-|', "sudo /usr/local/bin/traff.acc.3 m curr")
	or die ("Can't find traffic accounting script!");
   while (!eof(IN)) {
	my $q = readline (*IN);
	print $q."<br>";
   }
close (IN);

