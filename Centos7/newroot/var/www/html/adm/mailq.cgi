#!/usr/bin/perl
#use 5.006;
use CGI;

#replace 'u' with 'v' in 3 places -ash 28/01/16

my $query = new CGI;
#print $query->header(-charset=>'koi8-r');
print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><body style="background:#ddd;padding:20px;">};
my $u = $ENV{'REMOTE_USER'};
$u = "alex";#hack
my $user = $u;

#print "OK, you are $user";

for (my $c = 1; $c < 10;$c++) {

	if ($query->param('chb'.$c) eq 'on') {
		my $v = 'x'.$query->param('n'.$c);
		print STDERR 'Here '.$v."!\n";
		$query->param(-name=>'n'.$c, -value=>'');
		
		system("/usr/bin/sudo /usr/local/bin/rm_message $v");
		print STDERR 'Just deleted '.$v."!\n";

	}
$query->param(-name=>'chb'.$c, -value=>'');
}
sleep(1);
open (IN, '-|', "/bin/date;sudo /usr/bin/mailq")
	or die ("Can't find mailq!");
   my $counter = 0;
print qq{<form method="get" action="/" onsubmit="alert('Removing message');">};
     my $printnext = 0;
   while (!eof(IN)) {
	my $q = readline (*IN);
	$q =~ s/[<>]//g;
	my $l = $q =~ /@/ ? '<div style="padding-left:30px;color:#369;">' : '';
	my $r = $q =~ /@/ ? '</div>' : '<br>';
	$counter++ if ($q =~ /^x(\w+)/ && ($q =~ /$user/ || $u eq "alex"));
	my $chb = $q =~ /^x(\w+)/ ? '<input type=checkbox name=chb'.$counter.'><input type=hidden name=n'.$counter.' value='.$1.'>&nbsp;' : '';
	print $chb.$l.$q.$r if ($q =~ /$user/ || $u eq "alex" || $printnext) ;
	$printnext = ($q =~ /$user/) ? 1 : 0;
   }

my $str =  "<input type=submit name=Submit value=Delete><input type=hidden name=mode value=uc_mailq></form>";
$str = "No letters in queue - nothing to delete.</form>" if (!$counter);
print $str;
close (IN);
print qq{</body></html>};
exit;

