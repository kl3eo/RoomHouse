#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;
#print $query->header(-charset=>'koi8-r');
print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<head><title>Traffic counter</title></head><body style="background:#ddd;padding:20px;">};

open (IN, '-|', "sudo /usr/local/bin/traff.acc.3 m curr")
	or die ("Can't find traffic accounting script!");
	
while (!eof(IN)) {
	my $q = readline (*IN);
	print $q."<br>";
}
close (IN);

print qq{</body></html>};
exit;

