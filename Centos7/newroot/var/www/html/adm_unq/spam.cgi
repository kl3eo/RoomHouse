#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;
print $query->header(-charset=>'koi8-r');

local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required

my $scriptname = "spam.cgi";
my $file_name = "/tmp/sa-mimedefang.tmp";

my $mode = defined($query->param('mode')) ? $query->param('mode') : '';

if ($mode eq 'log_filter') {

print qq{<html><body>};	
	
	print "Отброшены письма:<br><br>";
		
	my $file = "/var/log/maillog";
	
	my $a = "sudo /bin/cat $file | grep discard_score";

	open (IN, '-|', $a) or die ("Can't cat!");	

	my $ll = '';
	while (my $q = <IN>) {
		
		$q =~ s/[<>]//g;
		my ($u,$d) = split('sa_discard_score',$q);	
		my @l = split (',',$d);
		
		$d = '';
		my $r = ''; my $cntr = 0;
		foreach my $line (@l) {
			$d = check_email_address($line,0);
			$d = $line unless ($d);
			$r .= " ".$d if ($d || $cntr);
			last if ($cntr);
			$cntr++ if ($d);
			
		}
		$q = $u." <b>".$r."</b>";
		
		print $q."<br>" unless ($ll eq $q);
		$ll = $q;
	}

	close (IN);
	
	print "<br><br>ended log!<br>";
print qq{</body></html>};
exit;	
}
 
unless ($mode eq "rm_spammer") {


print qq{<html><head><title>UNIQA spam list</title>};

print qq{
	<script language="JavaScript" type="text/javascript" src="/js/mootools-core-1.4.5-full-compat-yc.js"></script>
	<script language="JavaScript" type="text/javascript" src="/js/mootools-more-1.4.0.1a.js"></script>
	<script>
	function do_rm_spammer(s) {
		var form = document.createElement("form");
		form.setAttribute("method", "get");
		form.setAttribute("id", "myForm");

		document.body.appendChild(form); 

		\$('myForm').action = '$scriptname?mode=rm_spammer&spammer='+s;

		\$('myForm').send();
		\$('myForm').dispose();
		alert('please wait..READY ');
		location.href='$scriptname';
	}
	function open_log_window(){
		theString="$scriptname?mode=log_filter"
		win1=window.open(theString,"",'fullscreen=yes,toolbar=0,scrollbars=1,titlebar=0,resizable=1,menubar=0,status=0,location=0')
	}
	</script>
};

print qq{</head><body>};

print "Черный список почтового сервера dlx.uniqa.ru:<br>";
print "<div style=\"color:#369;text-decoration:underline;font-size:14px;font-weight:bold;margin:10px;\" onclick=\"javascript:open_log_window();\">Результаты</div><br>";
}
print qq{<br><br><form method="post" action="spam.cgi" onsubmit="var t = document.getElementById('sp').value.length ? document.getElementById('sp').value : 'ПУСТО';  alert('Добавить '+t+' в черный список?');">
                <div id=container>
                <div style="float:left;"><input id=sp type=text name=spammer VALUE=""></div>                <div style="float:left;margin-left:20px;"><input type=submit name=mode value=add_spammer></div>
                <div style="clear:left;"></div>
                </div>
        </form>
} unless ($mode eq "rm_spammer");

open (IN, '-|', "cat /etc/mail/sa-mimedefang.cf")
	or die ("Can't find file to read from!");

my $counter = 0;
my $newstr = '';
my $spammer = $query->param('spammer');
my $valid = check_email_address($spammer,0);

my $sstr = 'jejejehehehe';

if ($mode eq 'add_spammer' || $mode eq 'rm_spammer') {
	
	open(OUTF,">$file_name") or die ("Can't find file to write into!");

	$newstr = "blacklist_from ".$spammer."\n";
	my $pinged_res = 1;
	
if ($spammer =~ /^(\d+)\.(\d+)\.(\d+)/) {

my $dstr = "\\[".$1."\\.".$2."\\.".$3."\\.\\d{1,3}";
$sstr = $1."_".$2."_".$3;


$newstr = "header RCVD_FROM_$sstr Received =~ /$dstr/\nscore RCVD_FROM_$sstr 100.0\ndescribe RCVD_FROM_$sstr Received from $1.$2.$3.0/24\n";
} elsif ($mode eq 'add_spammer')  {
	$pinged_res = check_email_address($spammer,1);
	unless ($pinged_res) {
		print qq {
			<script>alert('Address $spammer non-existent! Please do IP blocking!');</script>
		};
		$newstr = '';
	}
}

	$newstr = '' if ( length($spammer) == 0 || !$valid);
}


print OUTF "Debug: sstr is $sstr, spammer is $spammer, newstr is $newstr!\n" if ($mode eq 'rm_spammer');

my $firstline = 0;
	
while (!eof(IN)) {

	my $q = readline (*IN);
	
	my $snd = ''; $snd = $1 if ($q =~ /^blacklist_from[\t\s]+(.+)$/);

	$snd = $1.".".$2.".".$3 if ($q =~ /^header RCVD_FROM_(\d+)_(\d+)_(\d+)\s(.+)$/);

	print OUTF $newstr if ($mode eq 'add_spammer' && ($q =~ /^blacklist_from[\t\s]+(.+)$/ || $q =~ /^header RCVD_FROM_(\d+)_(\d+)_(\d+)\s(.+)$/) && !$firstline);
	$firstline = 1 if ($q =~ /^blacklist_from[\t\s]+(.+)$/ || $q =~ /^header RCVD_FROM_(\d+)_(\d+)_(\d+)\s(.+)$/);
	
	my $l = length($snd) ? "<div style=\"padding-left:30px;color:#369;\" 
		onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\" 
		onclick=\"var yon = window.confirm('Убрать $snd из черного списка?');if (yon) {do_rm_spammer('$snd');}\">" : '';

	
	my $r = length($snd) ? '</div>' : '<br>';
	my $not_been = 1;$not_been = 0 if ($mode eq 'add_spammer' && $q eq $newstr);
	print $l.$snd.$r if (length($snd) && $mode ne "rm_spammer" && $not_been);
	
	$counter++  if (length($snd) && $not_been);

my $pinged_res = 1;

if ($mode eq 'add_spammer' && $q =~ /^blacklist_from[\t\s]+(.+)$/ && 0) {
	$snd = $1;
	$pinged_res = check_email_address($snd,1);
}	
	print OUTF $q if (($mode eq 'add_spammer' || $mode eq 'rm_spammer') && $q ne $newstr && $q !~ /$sstr/ && $pinged_res);

}

if ($mode eq 'add_spammer') {
	my $l = length($spammer) ? "<div style=\"padding-left:30px;color:#369;\" 
		onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\" 
		onclick=\"var yon = window.confirm('Убрать $spammer из черного списка?');if (yon) {do_rm_spammer('$spammer');}\">" : '';	
	my $r = length($spammer) ? '</div>' : '<br>';	
	print $l.$spammer.$r."<br>";
	$counter++ if (length($spammer));
}


my $str = "<br>Число blacklist-записей: $counter";
$str = "<br>No blacklist records found" if (!$counter);

if ($mode eq 'add_spammer' || $mode eq 'rm_spammer') {

	print OUTF $newstr if ($mode eq 'add_spammer' && !$firstline);
	close(OUTF);
	system("sudo /usr/local/bin/reload_mimedefang");
}

print $str unless ($mode eq "rm_spammer");

close (IN);

print qq{<br><br>
<!--form method="post" action="spam.cgi" onsubmit="var t = document.getElementById('sp').value.length ? document.getElementById('sp').value : 'ПУСТО';  alert('Добавить '+t+' в черный список?');">
		<div id=container>
		<div style="float:left;"><input id=sp type=text name=spammer VALUE=""></div>
		<div style="float:left;margin-left:20px;"><input type=submit name=mode value=add_spammer></div>
		<div style="clear:left;"></div>
		</div>
	</form-->
</body></html>} unless ($mode eq "rm_spammer");

sub check_email_address {

my $e = shift;
my $par = shift;

if ($e =~ /^(\w|\-|\_|\.|\*)+\@+((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/ && $par) {
	print "Testing $e:<br>";

	my ($a,$b) = split("@",$e);

	print "Testing $b from $e:<br>";

	my $r = Connect_ping($b);
	print "Result for $b: $r<br>";

	return 0 if (!$r && length($b));
}

return $e if ($e =~ /^(\w|\-|\_|\.|\*)+\@*((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/ || $e =~ /(\d+).(\d+).(\d+)/);

return 0;
}

sub Connect_ping {

my $test_url = shift;

my $tainted = 0;

my $wget_cmd = 'ping -c 1 -q '.$test_url;

eval {
	
alarm 3;

open (INN, '-|', $wget_cmd)
	or die ("Can't ping");

   while (!eof(INN)) {
	my $q = readline (*INN);

	if ( $q =~ /1 packets transmitted/ ) {

		$tainted = 1;
	
	}
	if ( $q =~ /unknown host/ ) {

		$tainted = 0;
	
	}
   }

close (INN);

alarm 0;
};

return $tainted;
} #end Connect
