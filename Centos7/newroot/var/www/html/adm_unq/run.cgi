#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;
print $query->header(-charset=>'koi8-r');

my $mode = defined($query->param('mode')) ? $query->param('mode') : '' ;
#print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">};

print qq{<html><head><title>UNIQA script run utility</title>
<script language="JavaScript">
function open_script_window(scr){
if (scr == "sm" ) {theString="smlight.cgi"} else 
if (scr == "mq" ) {theString="mailq.cgi"} else 
if (scr == "bl" ) {theString="spam.cgi"} else 
if (scr == "wl" ) {theString="whitelist.cgi"} else 
if (scr == "tz" ) {theString="traff.cgi"} else 
if (scr == "ty" ) {theString="traff_yota.cgi"} else 
if (scr == "ls" ) {theString="../lightsquid/"} else 
if (scr == "px" ) {theString="run.cgi?mode=restart_proxy"} else 
if (scr == "ts" ) {theString="run.cgi?mode=ntpdate"}
if (scr == "ry" ) {theString="run.cgi?mode=reboot_yota"}
if (scr == "au" ) {theString="add_user.cgi"}
if (scr == "du" ) {theString="del_user.cgi"}
if (scr == "pu" ) {theString="change_pass_user.cgi"}

win1=window.open(theString,"",'fullscreen=yes,toolbar=0,scrollbars=1,titlebar=0,resizable=1,menubar=0,status=0,location=0')
win1.moveTo(200,200)
}
</script>
</head><body>};

if ($mode eq '') {

my @par = ("sm","mq","bl","wl","tz","ty","ls","px","ts","ry", "au", "du", "pu");
my @t = ("Скрипт для просмотра логов почты", "Скрипт буфера отправки почты", 
"Blacklist", "Whitelist","Сумма трафика через PRI канал (с начала месяца)", 
"Сумма трафика через SEC канал (с начала месяца)",
"Lightsquid", "Перезапустить прокси Squid (<font color=#963><b>?!</b></font>)", "Сихронизовать время и перезапустить Sendmail (<font color=#963><b>?!</b></font>)", 
"Перезапустить Yota (<font color=#963><b>?!</b></font>)",
"Добавить пользователя",
"Удалить пользователя",
"Изменить пароль у пользователя");

print "<br><br>";

for (my $i = 0; $i < 4;$i++) {
	my $l = "<div style=\"padding-left:30px;color:#369;padding-top:5px;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

print "<br><br>";

for (my $i = 4; $i < 7;$i++) {
	my $l = "<div style=\"padding-left:30px;color:#369;padding-top:5px;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}


print "<br><br>";

for (my $i = 7; $i < 10;$i++) {
	my $l = "<div style=\"padding-left:30px;color:#369;padding-top:5px;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	#print $l.$t[$i].$r;
}

#print "<br><br>";

for (my $i = 10; $i < 12;$i++) {
	my $l = "<div style=\"padding-left:30px;color:#369;padding-top:5px;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

} elsif ($mode eq 'restart_proxy') {

	open (IN, '-|', "sudo /usr/local/bin/restart_squid.sh") or die ("Can't restart daemon!");

	while (my $q = <IN>) {
		
		print $q."<br>";

	}

	close (IN);
} elsif ($mode eq 'ntpdate') {

	open (IN, '-|', "sudo /usr/local/bin/ntpdate.sh") or die ("Can't sync time!");

	while (my $q = <IN>) {
		
		print $q."<br>";

	}

	close (IN);
} elsif ($mode eq 'reboot_yota') {

	open (IN, '-|', "sudo /usr/local/bin/reboot_yota.sh") or die ("Can't reboot yota!");

	while (my $q = <IN>) {
		
		print $q."<br>";

	}

	close (IN);
}

print qq{</body></html>};

