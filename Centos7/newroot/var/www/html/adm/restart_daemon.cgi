#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;
my $daemon = defined($query->param('caddon')) && length($query->param('caddon')) ? $query->param('caddon') : '';

print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<head><title>Restart daemon</title></head><body style="background:#435c70;">};

print qq{<div style="text-align:center;width:100%;margin-top:60px;">Please wait...</div>};

#print STDERR "Here daemon is $daemon!\n";

open (IN, '-|', "sudo /usr/local/bin/restart_$daemon.sh")
	or die ("Can't find the script!");

print "<div style=\"text-align:center;width:100%;margin-top:60px;\">";	
while (!eof(IN)) {
	my $q = readline (*IN);
	print "<div style=\"margin:0x auto;width:490px;background:#567086;font-size:16px;color:#9cf;padding:10px;line-height:20px;\">".$q."</div>";
}
print "</div>";
close (IN);

print qq{</body></html>};
exit;

