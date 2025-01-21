#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;
print $query->header(-charset=>'koi8-r');

my $u = $ENV{'REMOTE_USER'};
#$u = "gorbatov_k";

my @adm = ("alex","kirillov_k");

my $is_adm = &is_adm($u) ? 1 : 0;

my @filter = $is_adm ? () : ("kirillov_k","yakushik_a");

my $scriptname = "smlight.cgi";

my $mode = defined($query->param('mode')) ? $query->param('mode') : '';

$mode = "search_identifier" if ($mode eq '' && !$is_adm);

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

#print "OK, you are $u, adm is $is_adm!<br>";

if ($mode eq 'Stats' || $mode eq '') {

print qq{<form method="post" action="smlight.cgi">};
print qq{<div id=container>
	<div style="float:left;"><input type=radio name=period VALUE=0 $ch[0]>этот день</div>
	<div style="float:left;"><input type=radio name=period VALUE=1 $ch[1]>эта неделя</div>
	<div style="float:left;"><input type=radio name=period VALUE=2 $ch[2]>прошлая неделя</div>
	<!-- div style="float:left;"><input type=radio name=period VALUE=3 $ch[3]>за 4 недели</div -->
	<div style="float:left;margin-left:20px;"><input type=submit name=mode value=Stats></div>
	<div style="float:left;margin-left:20px;"><input type=submit name=mode value=Daemon></div>
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
	print $l.$q.$r unless ($q =~ /from=,/ || $q =~ /to=root,/ || contains_filter($q));
	$counter++  if ($q =~ /@/ && !($q =~ /from=,/ || $q =~ /to=root,/));
   }
my $str = "<br>Число учтенных записей: $counter";
$str = "<br>No records in log file so far - nothing to analyze." if (!$counter);
print $str;
close (IN);

} elsif ($mode eq 'log_filter' || $mode eq 'search_identifier') {
	
	my $sender = defined($query->param('sender')) ? $query->param('sender') : '';
	my $receiver = defined($query->param('receiver')) ? $query->param('receiver') : '';
	my $identifier = defined($query->param('ident')) ? $query->param('ident') : $u;

	my @s = split("\@", $sender);
	my @r = split("\@", $receiver);
	
	print "Пробуем фильтр на точное совпадение sender <b>$sender</b>, receiver <b>$receiver</b>!<br><br>"  if ($mode eq 'log_filter');
	print "Пробуем фильтр на точное совпадение <b>$identifier</b>!<br><br>"  if ($mode eq 'search_identifier');
	print qq{
	<div>
		<div style="float:left;margin-right:5px;">Поиск по идентификатору письма:</div>
		<form method="post" action="smlight.cgi">
			<div style="float:left;margin-left:5px;">
				<input type=text name=ident value="Copy ID" onfocus="this.value='';" 
				style="width:112px;font-family:Tahoma;font-size:12px;padding:3px;">
				<input type=submit name=mode value=search_identifier>
			</div>
			<div style="float:left;margin-left:20px;"><input type=submit name=mode value=Daemon></div>
		</form>
		<div style="clear:left;"></div>
	</div>
	} 
	#if ($mode eq 'log_filter')
	;
		
	my $file = "/var/log/maillog";
	$file = $file.".1" if ($period eq '2');
	
	#open (IN, '-|', "sudo /bin/cat $file | grep \"".$sender."\"| grep \"".$receiver."\"") or die ("Can't cat!");
	my $a = "sudo /bin/cat $file | grep \"<".$sender.">,<".$receiver.">\"";
	$a = "sudo /bin/cat $file | grep $identifier" if ($mode eq 'search_identifier');

	open (IN, '-|', $a) or die ("Can't cat!");	
	my $counter = 0;
	while (my $q = <IN>) {
		
		$q =~ s/[<>]//g;

		if ($period ne '0' ) {
			unless (contains_filter($q)) {
				print $q."<br>"; $counter++;
			}	
		} elsif ($period eq '0') {

			my @fields = split(" ", $q);
			my @months = ('Jan','Feb','Mar','Apr','May','Jun','Jul',
	       			'Aug','Sep','Oct','Nov','Dec');
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time+14400);
			my $cmpstr = $months[$mon]." ".$mday;			
			unless (contains_filter($q)) {
				print $q."<br>" if ($fields[0]." ".$fields[1] eq $cmpstr);
				$counter++ if ($fields[0]." ".$fields[1] eq $cmpstr);
			}
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
	
} elsif ($mode eq 'Daemon') {
my $if_restart = defined($query->param('rst')) ? $query->param('rst') : 0;

if ($if_restart) {

	open (INNA, '-|', "sudo /usr/local/bin/restart_sendmail.sh") or die ("Can't restart daemon!");

	while (my $q = <INNA>) {
		
		print $q."<br>";

	}

	close (INNA);
}
	
	
	open (INA, '-|', "sudo /usr/local/bin/check_sendmail.sh") or die ("Can't check daemon!");

	while (my $q = <INA>) {
		
		print $q."<br>";

	}

	close (INA);

print qq{<form method="post" action="smlight.cgi" onsubmit="alert('restarting..');">};
print qq{<div id=container>
	<div style="float:left;margin-left:120px;width:240px;">Перезапуск демона в тех случайях,<br>когда для этого <b>есть основания</b>!</div>
	<div style="float:left;margin-left:20px;">
		<input type=hidden name=rst value=1>
		<input type=submit name=mode value=Daemon></div>
	<div style="clear:left;"></div>
</div>
};

print qq{</form>};	
	
}

print qq{</body></html>};

sub contains_filter {
my $str = shift;

foreach my $m (@filter) {
	return 1 if ($str =~ /$m/);
}

return 0;
}

sub is_adm {
my $who = shift;

foreach my $m (@adm) {
	return 1 if ($who eq $m);
}

return 0;
}
