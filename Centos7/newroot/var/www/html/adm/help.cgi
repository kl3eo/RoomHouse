#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;

my $touch = defined($query->param('touch')) ? $query->param('touch') : 0;

my $pr = $touch ? "10px" : "30px";
my $pl = $touch ? "10px" : "60px";
my $ml = $touch ? "48px" : "48px";
my $mll = $touch ? "20px" : "20px";
my $wdth = $touch ? "320px" : "320px";

print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">};

print qq{<html><head><title>script run utility</title>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<script language="JavaScript">
function open_script_window(scr){
if (scr == "a" ) {theString="/?mode=h_a_user"} else 
if (scr == "b" ) {theString="/?mode=h_b_user"} else 
if (scr == "c" ) {theString="/?mode=h_c_user"} else 
if (scr == "d" ) {theString="/?mode=h_d_user"} else 
if (scr == "e" ) {theString="/?mode=h_e_user"} else 
if (scr == "f" ) {theString="/?mode=h_f_user"} else 
if (scr == "g" ) {theString="/?mode=h_g_user"} else 
if (scr == "h" ) {theString="/?mode=h_h_user"} else 
if (scr == "i" ) {theString="/?mode=h_i_user"} else 
if (scr == "j" ) {theString="/?mode=h_j_user"} else 
if (scr == "k" ) {theString="/?mode=h_k_user"} else 
if (scr == "l" ) {theString="/?mode=h_l_user"} else 
if (scr == "m" ) {theString="/?mode=h_m_user"} else 
if (scr == "n" ) {theString="/?mode=h_n_user"} else 
if (scr == "o" ) {theString="/?mode=h_o_user"} else 
if (scr == "p" ) {theString="/?mode=h_p_user"} else 
if (scr == "q" ) {theString="/?mode=h_q_user"} else 
if (scr == "r" ) {theString="/?mode=h_r_user"} else 
if (scr == "s" ) {theString="http://xetr.ru/glossary_ru.html"}

location.href=theString
}
</script>
</head><body style="background:#435c70;color:#fee;font-family:Tahoma;font-size:18px;font-weight:bold;padding-top:20px;text-align:left;">};

print qq{<div style="width:$wdth;float:left;margin-left:$mll;">};

my @par = ("a","b","c","g");
my @t = (koitoutf8("��������� BIOS"), koitoutf8("�������� �������"), koitoutf8("���������� xETR"), koitoutf8("���������"));

print "<br>";
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("���������� � ������")."</div>";
print "<br>";

for (my $i = 0; $i < 4;$i++) {
	my $l = "<div style=\"padding-left:60px;color:#fee;padding-top:5px;cursor:pointer;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

#print "<br>";
print "<br>";
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("��������� ����")."</div>";
print "<br>";

@par = ("d","e","f");
@t = (koitoutf8("Ethernet"), koitoutf8("WiFi"), koitoutf8("������� IP"));

for (my $i = 0; $i < 3;$i++) {
	my $l = "<div style=\"padding-left:60px;color:#fee;padding-top:5px;cursor:pointer;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

print "</div>";
print qq{<div style="width:$wdth;float:left;margin-left:$mll;">};

my @par = ("h","i","j");
my @t = (koitoutf8("Blacklist"), koitoutf8("����-TOR"), koitoutf8("���� ������"));

print "<br>";
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("�������� �� ����������")."</div>";
print "<br>";

for (my $i = 0; $i < 4;$i++) {
	my $l = "<div style=\"padding-left:60px;color:#fee;padding-top:5px;cursor:pointer;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

#print "<br>";
print "<br>";
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("���-������")."</div>";
print "<br>";

@par = ("k","l","m");
@t = (koitoutf8("Live Stream"), koitoutf8("������ �����+�����"), koitoutf8("������������� ��������"));

for (my $i = 0; $i < 3;$i++) {
	my $l = "<div style=\"padding-left:60px;color:#fee;padding-top:5px;cursor:pointer;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

print "</div>";
print qq{<div style="width:$wdth;float:left;margin-left:$mll;">};
my @par = ("n","o","p",'r');
my @t = (koitoutf8("�����"), koitoutf8("������"), koitoutf8("FTP, HTTP, FILE"), koitoutf8("���� ������"));

print "<br>";
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("������� �������")."</div>";
print "<br>";

for (my $i = 0; $i < 4;$i++) {
	my $l = "<div style=\"padding-left:60px;color:#fee;padding-top:5px;cursor:pointer;\" 
	onclick=\"javascript:open_script_window('$par[$i]');\" 
	onmouseover=\"this.style.textDecoration='underline';\" onmouseout=\"this.style.textDecoration='none';\">" ;
	my $r = "</div>"; 
	print $l.$t[$i].$r;
}

#print "<br>";
print "<br>";

print "<div style=\"margin-left:$ml;margin-top:22px;padding:10px 25px;color:#9cf;line-height:20px;background:#567086;font-size:14px;width:190px;border-radius:20px;\">".koitoutf8("������������ ��������<br>�� <span style='color:#fed;text-decoration:underline;'>������� �������</span><span style='font-style:italic;color:963;font-size:24px;'>&nbsp;!..</span><br>����� �� <span style='color:#fed;'>19990 ���.</span>").
"</div>";
print "</div>";
print qq{<div style="clear:left;"><div>};
print "<br>";
print "<br>";
print qq{</body></html>};
exit;

sub koitoutf8 { #26

my $pvdcoderwin=shift;

$pvdcoderwin=~ s/�/E/g;
$pvdcoderwin=~ s/�/e/g;
$pvdcoderwin=~ s/�/я/g;
$pvdcoderwin=~ s/�/п/g;

$pvdcoderwin=~ s/�/А/g;
$pvdcoderwin=~ s/�/Б/g;
$pvdcoderwin=~ s/�/В/g;
$pvdcoderwin=~ s/�/Г/g;
$pvdcoderwin=~ s/�/Д/g;
$pvdcoderwin=~ s/�/Е/g;
$pvdcoderwin=~ s/�/Ж/g;
$pvdcoderwin=~ s/�/З/g;
$pvdcoderwin=~ s/�/И/g;
$pvdcoderwin=~ s/�/Й/g;
$pvdcoderwin=~ s/�/К/g;
$pvdcoderwin=~ s/�/Л/g;
$pvdcoderwin=~ s/�/М/g;
$pvdcoderwin=~ s/�/Н/g;
$pvdcoderwin=~ s/�/О/g;
$pvdcoderwin=~ s/�/П/g;
$pvdcoderwin=~ s/�/Р/g;
$pvdcoderwin=~ s/�/С/g;
$pvdcoderwin=~ s/�/Т/g;
$pvdcoderwin=~ s/�/У/g;
$pvdcoderwin=~ s/�/Ф/g;
$pvdcoderwin=~ s/�/Х/g;
$pvdcoderwin=~ s/�/Ц/g;
$pvdcoderwin=~ s/�/Ч/g;
$pvdcoderwin=~ s/�/Ш/g;
$pvdcoderwin=~ s/�/Щ/g;
$pvdcoderwin=~ s/�/Ь/g;
$pvdcoderwin=~ s/�/Ы/g;
$pvdcoderwin=~ s/�/Ъ/g;
$pvdcoderwin=~ s/�/Э/g;
$pvdcoderwin=~ s/�/Ю/g;
$pvdcoderwin=~ s/�/Я/g;

$pvdcoderwin=~ s/�/а/g;
$pvdcoderwin=~ s/�/б/g;
$pvdcoderwin=~ s/�/в/g;
$pvdcoderwin=~ s/�/г/g;
$pvdcoderwin=~ s/�/д/g;
$pvdcoderwin=~ s/�/е/g;
$pvdcoderwin=~ s/�/ж/g;
$pvdcoderwin=~ s/�/з/g;
$pvdcoderwin=~ s/�/и/g;
$pvdcoderwin=~ s/�/й/g;
$pvdcoderwin=~ s/�/к/g;
$pvdcoderwin=~ s/�/л/g;
$pvdcoderwin=~ s/�/м/g;
$pvdcoderwin=~ s/�/н/g;
$pvdcoderwin=~ s/�/о/g;
$pvdcoderwin=~ s/�/р/g;
$pvdcoderwin=~ s/�/с/g;
$pvdcoderwin=~ s/�/т/g;
$pvdcoderwin=~ s/�/у/g;
$pvdcoderwin=~ s/�/ф/g;
$pvdcoderwin=~ s/�/х/g;
$pvdcoderwin=~ s/�/ц/g;
$pvdcoderwin=~ s/�/ч/g;
$pvdcoderwin=~ s/�/ш/g;
$pvdcoderwin=~ s/�/щ/g;
$pvdcoderwin=~ s/�/ь/g;
$pvdcoderwin=~ s/�/ы/g;
$pvdcoderwin=~ s/�/ъ/g;
$pvdcoderwin=~ s/�/э/g;
$pvdcoderwin=~ s/�/ю/g;

return $pvdcoderwin;
}
