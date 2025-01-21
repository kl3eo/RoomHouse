#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;
print $query->header(-charset=>'koi8-r');

my $scriptname = "whitelist.cgi";
my $file_name = "/tmp/sa-mimedefang.tmp";

my $mode = defined($query->param('mode')) ? $query->param('mode') : '';

 
unless ($mode eq "rm_wlrecord") {


print qq{<html><head><title>UNIQA white list</title>};

print qq{
	<script language="JavaScript" type="text/javascript" src="/js/mootools-core-1.4.5-full-compat-yc.js"></script>
	<script language="JavaScript" type="text/javascript" src="/js/mootools-more-1.4.0.1a.js"></script>
	<script>
	function do_rm_wlrecord(s) {
		var form = document.createElement("form");
		form.setAttribute("method", "get");
		form.setAttribute("id", "myForm");

		document.body.appendChild(form); 

		\$('myForm').action = '$scriptname?mode=rm_wlrecord&wlrecord='+s;

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

print "WHITE-LIST почтового сервера dlx.uniqa.ru:<br>";
#print "<div style=\"color:#369;text-decoration:underline;font-size:14px;font-weight:bold;margin:10px;\" onclick=\"javascript:open_log_window();\">Результаты</div><br>";
}
print qq{<br><br><form method="post" action="whitelist.cgi" onsubmit="var t = document.getElementById('sp').value.length ? document.getElementById('sp').value : 'ПУСТО';  alert('Добавить '+t+' в WHITELIST?');">
                <div id=container>
                <div style="float:left;"><input id=sp type=text name=wlrecord VALUE=""></div>                <div style="float:left;margin-left:20px;"><input type=submit name=mode value=add_wlrecord></div>
                <div style="clear:left;"></div>
                </div>
        </form>
} unless ($mode eq "rm_wlrecord");

open (IN, '-|', "cat /etc/mail/sa-mimedefang.cf")
	or die ("Can't find file to read from!");

my $counter = 0;
my $newstr = '';
my $wlrecord = $query->param('wlrecord');
my $valid = check_email_address($wlrecord);

if ($mode eq 'add_wlrecord' || $mode eq 'rm_wlrecord') {
	
	open(OUTF,">$file_name") or die ("Can't find file to write into!");
	$newstr = "whitelist_from ".$wlrecord."\n";
	$newstr = '' if ( length($wlrecord) == 0 || !$valid);
}

my $firstline = 0;
	
while (!eof(IN)) {
	my $q = readline (*IN);
	
	my $snd = ''; $snd = $1 if ($q =~ /^whitelist_from[\t\s]+(.+)$/);

	print OUTF $newstr if ($mode eq 'add_wlrecord' && $q =~ /^whitelist_from[\t\s]+(.+)$/ && !$firstline);
	$firstline = 1 if ($q =~ /^whitelist_from[\t\s]+(.+)$/);
	
	my $l = length($snd) ? "<div style=\"padding-left:30px;color:#369;\" 
		onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\" 
		onclick=\"var yon = window.confirm('Убрать $snd из WHITE-LIST?');if (yon) {do_rm_wlrecord('$snd');}\">" : '';

	
	my $r = length($snd) ? '</div>' : '<br>';
	my $not_been = 1;$not_been = 0 if ($mode eq 'add_wlrecord' && $q eq $newstr);
	print $l.$snd.$r if (length($snd) && $mode ne "rm_wlrecord" && $not_been);
	
	$counter++  if (length($snd) && $not_been);
	
	print OUTF $q if (($mode eq 'add_wlrecord' || $mode eq 'rm_wlrecord') && $q ne $newstr);

}

if ($mode eq 'add_wlrecord') {
	my $l = length($wlrecord) ? "<div style=\"padding-left:30px;color:#369;\" 
		onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\" 
		onclick=\"var yon = window.confirm('Убрать $wlrecord из WHITE-LIST?');if (yon) {do_rm_wlrecord('$wlrecord');}\">" : '';	
	my $r = length($wlrecord) ? '</div>' : '<br>';	
	print $l.$wlrecord.$r."<br>";
	$counter++ if (length($wlrecord));
}


my $str = "<br>Число whitelist-записей: $counter";
$str = "<br>No whitelist records found" if (!$counter);

if ($mode eq 'add_wlrecord' || $mode eq 'rm_wlrecord') {
	print OUTF $newstr if ($mode eq 'add_wlrecord' && !$firstline);
	close(OUTF);
	system("sudo /usr/local/bin/reload_mimedefang");
}

print $str unless ($mode eq "rm_wlrecord");

close (IN);

print qq{<br><br>
<!--form method="post" action="whitelist.cgi" onsubmit="var t = document.getElementById('sp').value.length ? document.getElementById('sp').value : 'ПУСТО';  alert('Добавить '+t+' в WHITELIST?');">
		<div id=container>
		<div style="float:left;"><input id=sp type=text name=wlrecord VALUE=""></div>
		<div style="float:left;margin-left:20px;"><input type=submit name=mode value=add_wlrecord></div>
		<div style="clear:left;"></div>
		</div>
	</form-->
</body></html>} unless ($mode eq "rm_wlrecord");

sub check_email_address {

my $e = shift;

return $e if ($e =~ /^(\w|\-|\_|\.|\*)+\@*((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/);
return 0;
}
