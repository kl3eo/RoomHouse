#!/usr/bin/perl
#use 5.006;

use CGI;

my $q = new CGI;

my $part = defined($q->param('part')) ? $q->param('part') : 0 ;

print STDERR "Here part is $part!\n";
print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">};

my $title_text = koitoutf8("Установка Windows");
my $content_text = koitoutf8("1.Скачайте с <a href=\"https://www.microsoft.com/ru-ru/software-download/windows10ISO\" target=new>сайта Microsoft</a> ISO-файл установки размера ~5Gb и сохраните его в корневом каталоге на флэшке как <b>win.iso</b>. Откройте эту <a href=\"https://xetr.ru/whelp/win_help.html\" target=new>инструкцию</a>.<br>2. Вставьте флэшку с файлом в USB-порт и нажмите <a href=javascript:open_script_window(\"wi\")>сюда</a>");

my $title_text1 = koitoutf8("Режим")." paranoid";
my $content_text1 = koitoutf8("Работа с выключенной сетью у Windows, чтобы не беспокоиться за конфиденциальность. Нажмите <a href=javascript:open_script_window(\"wr0\")>здесь</a>.");

my $title_text2 = koitoutf8("Обычный режим");
my $content_text2 = koitoutf8("Работа с ВКЛЮЧЕННОЙ сетью у Windows, так что будет возможна \"утечка\" информации через Интернет. Подтвердите включение, нажав <a href=# onclick=\"var yon = window.confirm(\\'Really?!\\');if (yon) {open_script_window(\\'wr1\\')}\">сюда</a>.");

my $title_text3 = koitoutf8("Обмен файлами");
my $content_text3 = koitoutf8("Обмен файлами с Windows возможен через особую папку (диск Z:). Откройте ее, нажав <a href=javascript:open_script_window(\"wf\")>сюда</a>.");

print qq{<html><head><title>UNIQA script run utility</title>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<script language="JavaScript">
function open_script_window(scr){
var yon = true;
if (scr == "sm" ) {theString="/?mode=uc_smlight"} else 
if (scr == "mq" ) {theString="/?mode=uc_mailq"} else 
if (scr == "bl" ) {theString="/?mode=uc_spam"} else 
if (scr == "wl" ) {theString="/?mode=uc_whitelist"} else 
if (scr == "tz" ) {theString="/?mode=uc_traff"} else 
if (scr == "ty" ) {theString="/?mode=uc_traff_yota"} else 
if (scr == "px" ) {theString="/?mode=uc_restart&caddon=squid";yon = window.confirm('Stop/Start this service?')} else 
if (scr == "ts" ) {theString="/?mode=uc_restart&caddon=sendmail";yon = window.confirm('Stop/Start this service?')} else 
if (scr == "ry" ) {theString="/?mode=uc_restart&caddon=cyrus";yon = window.confirm('Stop/Start this service?')} else 
if (scr == "hy" ) {theString="/?mode=uc_restart&caddon=http";yon = window.confirm('Restart this service?')} else 
if (scr == "fy" ) {theString="/?mode=uc_restart&caddon=wftp";yon = window.confirm('Stop/Start this service?')} else 
if (scr == "py" ) {theString="/?mode=uc_restart&caddon=pg";yon = window.confirm('Restart this service?')} else 
if (scr == "sy" ) {theString="/?mode=uc_restart&caddon=smb";yon = window.confirm('Restart this service?')} else 
if (scr == "ny" ) {theString="/?mode=uc_restart&caddon=named";yon = window.confirm('Restart this service?')} else 
if (scr == "au" ) {theString="/?mode=uc_add_user"} else 
if (scr == "du" ) {theString="/?mode=uc_del_user"} else 
if (scr == "wi" ) {theString="/?mode=uc_inst_win"} else 
if (scr == "wr0" ) {theString="/?mode=uc_run_win&run=0"} else 
if (scr == "wr1" ) {theString="/?mode=uc_run_win&run=1"} else
if (scr == "ws" ) {theString="/?mode=uc_stop_win"} else  
if (scr == "wf" ) {theString="/?mode=uc_files_win"} else 
if (scr == "wd" ) {theString="/?mode=uc_deinst_win"}


if (yon) {location.href=theString}
}

function warner(scr){
	alert('Daemon disabled');
}

</script>
<script language="JavaScript" type="text/javascript" src="/js/mootools-core-1.3-full-compat-yc.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/mootools-more.js"></script>

<script language="JavaScript" type="text/javascript" src="/js/mBox.Core.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/mBox.Tooltip.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/mBox.Modal.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/mBox.Modal.Confirm.js"></script>

<script>
window.addEvent('domready', function() {
	
	new mBox.Modal({
		content: '$content_text',
		setStyles: {content: {padding: '25px 15px', lineHeight: 25}},
		width:200,
		title: '$title_text',
		attach: 'setup_win'
	});
	
	new mBox.Modal({
		content: '$content_text1',
		setStyles: {content: {padding: '25px 15px', lineHeight: 25}},
		width:200,
		title: '$title_text1',
		attach: 'run_win0'
	});
			
	new mBox.Modal({
		content: '$content_text2',
		setStyles: {content: {padding: '25px 15px', lineHeight: 25}},
		width:200,
		title: '$title_text2',
		attach: 'run_win1'
	});

	new mBox.Modal({
		content: '$content_text3',
		setStyles: {content: {padding: '25px 15px', lineHeight: 25}},
		width:200,
		title: '$title_text3',
		attach: 'files_win'
	});
		
});

</script>


<link rel="stylesheet" href="/css/mBoxCore.css" type="text/css" media="screen" />
<link rel="stylesheet" type="text/css" href="/css/mBoxModal.css" />
<link rel="stylesheet" href="/css/mBoxTooltip.css" type="text/css" media="screen" />
<link rel="stylesheet" href="/css/mBoxTooltip-Gradient.css" type="text/css" media="screen" />

<style>
.star, .rightstar {
margin-left:20px;padding-left:30px;color:#9cf;padding-top:15px;cursor:pointer;font-family:Courier;font-weight:bold;
}
.rightstar {
border:1px solid #222;
}
</style>
</head><body style="background:#435c70;">};

my @par = ("sm","mq","bl","wl","tz","ty","px","ts","ry","sy","hy","fy","py","ny","au", "du","wi","wr0","wr1","ws");
my @t = ("п©я─п╬я│п╪п╬я┌я─ п╩п╬пЁп╬п╡ п©п╬я┤я┌я▀", "п╠я┐я└п╣я─ п╬я┌п©я─п╟п╡п╨п╦ п©п╬я┤я┌я▀", 
"Blacklist п©п╬я┤я┌я▀", "Whitelist п©п╬я┤я┌я▀","я┌я─п╟я└п╦п╨ я┤п╣я─п╣п╥ PRI п╨п╟п╫п╟п╩", 
"я┌я─п╟я└п╦п╨ я┤п╣я─п╣п╥ SEC п╨п╟п╫п╟п╩",
koitoutf8("Proxy"), koitoutf8("SMTP"), koitoutf8("IMAP"), koitoutf8("Samba"), koitoutf8("HTTP"),
koitoutf8("FTP"), koitoutf8("DB"), koitoutf8("DNS"),
"п■п╬п╠п╟п╡п╦я┌я▄ п©п╬п╩я▄п╥п╬п╡п╟я┌п╣п╩я▐",
"пёп╢п╟п╩п╦я┌я▄ п©п╬п╩я▄п╥п╬п╡п╟я┌п╣п╩я▐");

if ($part == 1 || $part == 0) {

print "<br><span style=\"float:left;margin-left:20px;color:#fed;text-decoration:underline;\">Utilities</span><br><br>";

for (my $i = 0; $i < 2;$i++) {
	my $l = "<div class=star 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

for (my $i = 2; $i < 4;$i++) {
	my $l = "<div class=star 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

for (my $i = 4; $i < 6;$i++) {
	my $l = "<div class=star
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

for (my $i = 14; $i < 16;$i++) {
	my $l = "<div class=star
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

} elsif ($part == 2 || $part == 0) {

my $ri = 
#$touch_specific_bro ? "left" : 
"left";

print qq{<div><div style="width:50%;float:left;">};

print "<br><span style=\"float:$ri;margin-$ri:20px;color:#fed;text-decoration:underline;\">Services</span><br><br>";

for (my $i = 6; $i < 14;$i++) {

my $running_state = "running..";
my $clr = "#396";

my $ret = `sudo /usr/local/bin/check_daemons.pl $par[$i]`;

$running_state = "stopped" unless ($ret =~ /^\d+$/);
$clr = "#933" unless ($ret =~ /^\d+$/);

$running_state = "disabled"  if ($ret == -1);
$clr = "#eee" if ($ret == -1);	

my $jsfunc = $ret == -1 ? "warner" : "open_script_window";

my $a = "<div style=\"font-weight:normal; color:$clr;float:left;font-size:14px;\">$running_state</div>";

	my $l = "<div style=\"float:left;margin:0px 10px;font-size:16px;font-weight:bold;color:#9cf;font-family:Courier;cursor:pointer;\" onclick=\"javascript:$jsfunc('$par[$i]');\" onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div><div style=\"clear:left;\"></div>"; 
	print "<div style=\"width:100%;margin:15px 3px;\"><div style=\"float:$ri;margin-$ri:18px;\">".$a.$l.$t[$i].$r."</div><div style=\"clear:$ri;\"></div></div>";
}
print qq{</div><div style="width:50%;float:left;">};

#see what happens with windows right now

my $winfile_exists = 0;
$winfile_exists = 1 if (-f "/opt/nvme/ssd/vm.img" && -s "/opt/nvme/ssd/vm.img" > 25000000000);

my $wstate = '';
my $wruns = 0;#not running
$wruns = `sudo /usr/local/bin/ps.sh| grep "qemu-system-x86_64 --enable-kvm -drive driver=raw,file=/opt/nvme/ssd/vm/win10.img" |  grep -v grep | awk '{print \$2}'`;$wruns =~ s/(\r|\n)//g;
$wstate = "running" if ($wruns =~ /^\d+$/ && $wruns > 0);

my $wpass = '';
$wpass = `sudo /usr/local/bin/ps.sh | grep "/usr/bin/sudo /usr/local/bin/create_qemu.sh" |  grep -v grep | awk '{print \$15}'`;$wpass =~ s/(\r|\n)//g;
$wstate = "running inst with pass $wpass" if (length($wpass) && $wstate eq "running");

if ($wstate eq "running" && $wpass eq '') {

	$wpass = `sudo /usr/local/bin/ps.sh | grep "/usr/bin/sudo /usr/local/bin/create_go.sh" |  grep -v grep | awk '{print \$15}'`;$wpass =~ s/(\r|\n)//g;
	$wstate = "running go with pass $wpass" if (length($wpass));

}

if ($wstate eq "running" && $wpass eq '') {

	$wstate = "undefined";

}

print STDERR "here wstate is $wstate!\n";

my $inst_active_passive = "color:#9cf;cursor:pointer";
my $run_active_passive = "color:#888";
my $run0_active_passive = "color:#888";
my $wstop_active_passive = "color:#888";
my $wdeinst_active_passive = "color:#888";
my $wfiles_active_passive = "color:#888";

my $setup_win = " class=setup_win";
my $run_win0 = '';
my $run_win1 = '';

my $run1_o = '';

my $wstop_o = '';
my $wdeinst_o = '';

if (length($wstate) || $winfile_exists) {
	$setup_win = '';
	$inst_active_passive = "color:#888";
	$run0_active_passive = "color:#9cf;cursor:pointer";
	$run_active_passive = "color:#9cf;cursor:pointer";
	$wstop_active_passive = "color:#9cf;cursor:pointer" if ( length($wstate) );
	$wfiles_active_passive = "color:#9cf;cursor:pointer";
	$wdeinst_active_passive = "color:#9cf;cursor:pointer" unless ( length($wstate) );
	$run_win0 = " class=run_win0";
	#$run_win1 = " class=run_win1";
	$files_win = " class=files_win";
	$run1_o = " onclick=\"open_script_window('wr1');\"";
	$wstop_o = " onclick=\"open_script_window('ws');\"" if ( length($wstate) );
	$wdeinst_o = " onclick=\"open_script_window('wd');\"" unless ( length($wstate) );
}

print "<br><span style=\"float:right;margin-right:20px;color:#fed;text-decoration:underline;\">Windows</span><br><br>";
my $setup = koitoutf8("инсталляция");my $work0 = "paranoid";my $work1 = koitoutf8("работа");
my $wfiles = koitoutf8("файлы");my $wstop = koitoutf8("стоп");my $wdeinst = koitoutf8("деинсталляция");
print qq{<div$setup_win style="font-family:Courier;text-align:right;margin:15px 30px 15px -20px;font-weight:bold;font-size:16px;$inst_active_passive;width:100%;">...$setup</div>};
print qq{<div$run_win1 style="font-family:Courier;text-align:right;margin:25px 30px 15px -20px;font-weight:bold;font-size:16px;$run_active_passive;width:100%;"$run1_o>...$work1</div>};
print qq{<div$run_win0 style="font-family:Courier;text-align:right;margin:25px 30px 15px -20px;font-weight:bold;font-size:16px;$run0_active_passive;width:100%;">...$work0</div>};
print qq{<div style="font-family:Courier;text-align:right;margin:25px 30px 15px -20px;font-weight:bold;font-size:16px;$wstop_active_passive;width:100%;"$wstop_o>...$wstop</div>};
print qq{<div$files_win style="font-family:Courier;text-align:right;margin:25px 30px 15px -20px;font-weight:bold;font-size:16px;$wfiles_active_passive;width:100%;">...$wfiles</div>};
print qq{<div style="font-family:Courier;text-align:right;margin:25px 30px 15px -20px;font-weight:bold;font-size:16px;$wdeinst_active_passive;width:100%;"$wdeinst_o>...$wdeinst</div>};

print qq{</div></div>};
} #part 2

exit;

print qq{
</body></html>};


sub koitoutf8 { #26

my $pvdcoderwin=shift;

$pvdcoderwin=~ s/Ё/E/g;
$pvdcoderwin=~ s/ё/e/g;
$pvdcoderwin=~ s/я/я▐/g;
$pvdcoderwin=~ s/п/п©/g;

$pvdcoderwin=~ s/А/п░/g;
$pvdcoderwin=~ s/Б/п▒/g;
$pvdcoderwin=~ s/В/п▓/g;
$pvdcoderwin=~ s/Г/п⌠/g;
$pvdcoderwin=~ s/Д/п■/g;
$pvdcoderwin=~ s/Е/п∙/g;
$pvdcoderwin=~ s/Ж/п√/g;
$pvdcoderwin=~ s/З/п≈/g;
$pvdcoderwin=~ s/И/п≤/g;
$pvdcoderwin=~ s/Й/п≥/g;
$pvdcoderwin=~ s/К/п /g;
$pvdcoderwin=~ s/Л/п⌡/g;
$pvdcoderwin=~ s/М/п°/g;
$pvdcoderwin=~ s/Н/п²/g;
$pvdcoderwin=~ s/О/п·/g;
$pvdcoderwin=~ s/П/п÷/g;
$pvdcoderwin=~ s/Р/п═/g;
$pvdcoderwin=~ s/С/п║/g;
$pvdcoderwin=~ s/Т/п╒/g;
$pvdcoderwin=~ s/У/пё/g;
$pvdcoderwin=~ s/Ф/п╓/g;
$pvdcoderwin=~ s/Х/п╔/g;
$pvdcoderwin=~ s/Ц/п╕/g;
$pvdcoderwin=~ s/Ч/п╖/g;
$pvdcoderwin=~ s/Ш/п╗/g;
$pvdcoderwin=~ s/Щ/п╘/g;
$pvdcoderwin=~ s/Ь/п╛/g;
$pvdcoderwin=~ s/Ы/п╚/g;
$pvdcoderwin=~ s/Ъ/п╙/g;
$pvdcoderwin=~ s/Э/п╜/g;
$pvdcoderwin=~ s/Ю/п╝/g;
$pvdcoderwin=~ s/Я/п╞/g;

$pvdcoderwin=~ s/а/п╟/g;
$pvdcoderwin=~ s/б/п╠/g;
$pvdcoderwin=~ s/в/п╡/g;
$pvdcoderwin=~ s/г/пЁ/g;
$pvdcoderwin=~ s/д/п╢/g;
$pvdcoderwin=~ s/е/п╣/g;
$pvdcoderwin=~ s/ж/п╤/g;
$pvdcoderwin=~ s/з/п╥/g;
$pvdcoderwin=~ s/и/п╦/g;
$pvdcoderwin=~ s/й/п╧/g;
$pvdcoderwin=~ s/к/п╨/g;
$pvdcoderwin=~ s/л/п╩/g;
$pvdcoderwin=~ s/м/п╪/g;
$pvdcoderwin=~ s/н/п╫/g;
$pvdcoderwin=~ s/о/п╬/g;
$pvdcoderwin=~ s/р/я─/g;
$pvdcoderwin=~ s/с/я│/g;
$pvdcoderwin=~ s/т/я┌/g;
$pvdcoderwin=~ s/у/я┐/g;
$pvdcoderwin=~ s/ф/я└/g;
$pvdcoderwin=~ s/х/я┘/g;
$pvdcoderwin=~ s/ц/я├/g;
$pvdcoderwin=~ s/ч/я┤/g;
$pvdcoderwin=~ s/ш/я┬/g;
$pvdcoderwin=~ s/щ/я┴/g;
$pvdcoderwin=~ s/ь/я▄/g;
$pvdcoderwin=~ s/ы/я▀/g;
$pvdcoderwin=~ s/ъ/я┼/g;
$pvdcoderwin=~ s/э/я█/g;
$pvdcoderwin=~ s/ю/я▌/g;

return $pvdcoderwin;
}
