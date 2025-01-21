#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;
print $query->header(-charset=>'koi8-r');

my $scriptname = "sm_log.cgi";

my $mode = defined($query->param('mode')) ? $query->param('mode') : '';
my $period = defined($query->param('period')) ? $query->param('period') : 1;;

my @ch = ('',"checked",'','');
@ch = ("checked",'','','') if ($period eq '0');
@ch = ('','',"checked",'') if ($period eq '2');
@ch = ('','','',"checked") if ($period eq '3');

print qq{<html><head><title>UNIQA mail log analyzer utility</title>
<script language="JavaScript">
function open_log_window(s, r, p){
theString="$scriptname?mode=log_filter&sender="+s+"&receiver="+r+"&period="+p
win1=window.open(theString,"",'fullscreen=yes,toolbar=0,scrollbars=1,titlebar=0,resizable=1,menubar=0,status=0,location=0')
win1.moveTo(200,200)
}
</script>
</head><body>};

if ($mode eq 'Stats' || $mode eq '') {

print qq{<form method="post" action="sm_log.cgi" onsubmit="alert('Посчитать заново?');">};
print qq{<div id=container>
	<div style="float:left;"><input type=radio name=period VALUE=0 $ch[0]>этот день</div>
	<div style="float:left;"><input type=radio name=period VALUE=1 $ch[1]>эта неделя</div>
	<div style="float:left;"><input type=radio name=period VALUE=2 $ch[2]>прошлая неделя</div>
	<!-- div style="float:left;"><input type=radio name=period VALUE=3 $ch[3]>за 4 недели</div -->
	<div style="float:left;margin-left:20px;"><input type=submit name=mode value=Stats></div>
	<div style="clear:left;"></div>
</div>
};

print qq{</form>};

open (IN, '-|', "sudo /usr/local/bin/sendmail_log_parser $period")
	or die ("Can't find sendmail_log_parser!");
   my $counter = 0;

   while (!eof(IN)) {
	my $q = readline (*IN);
	$q =~ s/[<>]//g;
	$q =~ /from=(.+?),/; my $snd = $1;
	$q =~ /to=(.+),/; my $rcv = $1;

	my $l = $q =~ /@/ ? "<div style=\"padding-left:30px;color:#369;\" 
	onclick=\"javascript:open_log_window('$snd', '$rcv', $period);\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" : '';
	my $r = $q =~ /@/ ? '</div>' : '<br>';
	print $l.$q.$r unless ($q =~ /from=,/ || $q =~ /to=root,/);
	$counter++  if ($q =~ /@/ && !($q =~ /from=,/ || $q =~ /to=root,/));
   }
my $str = "<br>Число учтенных записей: $counter";
$str = "<br>No records in log file so far - nothing to analyze." if (!$counter);
print $str;
close (IN);

} elsif ($mode eq 'log_filter') {
	
	my $sender = defined($query->param('sender')) ? $query->param('sender') : '';
	my $receiver = defined($query->param('receiver')) ? $query->param('receiver') : '';

	my @s = split("\@", $sender);
	my @r = split("\@", $receiver);
	
	print "Пробуем фильтр на точное совпадение sender <b>$sender</b>, receiver <b>$receiver</b>!<br><br>";
		
	my $file = "/var/log/maillog";
	$file = $file.".1" if ($period eq '2');
	
	#open (IN, '-|', "sudo /bin/cat $file | grep \"".$sender."\"| grep \"".$receiver."\"") or die ("Can't cat!");
	my $a = "sudo /bin/cat $file | grep \"<".$sender.">,<".$receiver.">\"";

	open (IN, '-|', $a) or die ("Can't cat!");	
	my $counter = 0;
	while (my $q = <IN>) {
		
		$q =~ s/[<>]//g;

		if ($period ne '0' ) {
			print $q."<br>"; $counter++;
		} elsif ($period eq '0') {

			my @fields = split(" ", $q);
			my @months = ('Jan','Feb','Mar','Apr','May','Jun','Jul',
	       			'Aug','Sep','Oct','Nov','Dec');
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time+14400);
			my $cmpstr = $months[$mon]." ".$mday;			

			print $q."<br>" if ($fields[0]." ".$fields[1] eq $cmpstr);
			$counter++ if ($fields[0]." ".$fields[1] eq $cmpstr);
		}
	}

	close (IN);
	
	
	if ($counter == 0) {
		#print "No exact matching found, trying filter on <b>sender</b> and <b>receiver</b> fields separately:<br><br>";
		print "Точных совпадений не найдено, пробуем фильтр на <b>sender</b> и <b>receiver</b> по отдельности:<br><br>";
	open (INN, '-|', "sudo /bin/cat $file | grep \"".$receiver."\"") or die ("Can't cat!");

	while (my $q = <INN>) {
		
		$q =~ s/[<>]//g;

		if ($period ne '0' ) {
			print $q."<br>";
		} elsif ($period eq '0') {

			my @fields = split(" ", $q);
			my @months = ('Jan','Feb','Mar','Apr','May','Jun','Jul',
	       			'Aug','Sep','Oct','Nov','Dec');
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time+14400);
			my $cmpstr = $months[$mon]." ".$mday;			

			print $q."<br>" if ($fields[0]." ".$fields[1] eq $cmpstr);
		}
	}

	close (INN);	
	open (INNN, '-|', "sudo /bin/cat $file | grep \"".$sender."\"") or die ("Can't cat!");

	while (my $q = <INNN>) {
		
		$q =~ s/[<>]//g;

		if ($period ne '0' ) {
			print $q."<br>";
		} elsif ($period eq '0') {

			my @fields = split(" ", $q);
			my @months = ('Jan','Feb','Mar','Apr','May','Jun','Jul',
	       			'Aug','Sep','Oct','Nov','Dec');
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time+14400);
			my $cmpstr = $months[$mon]." ".$mday;			

			print $q."<br>" if ($fields[0]." ".$fields[1] eq $cmpstr);
		}
	}

	close (INNN);	
	}
	
	print "<br><br>ended log!<br>";
	
}

print qq{</body></html>};

