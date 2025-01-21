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
my @t = (koitoutf8("Настройки BIOS"), koitoutf8("Загрузка системы"), koitoutf8("Обновления xETR"), koitoutf8("Интерфейс"));

print "<br>";
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("Подготовка к работе")."</div>";
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
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("Настройка сети")."</div>";
print "<br>";

@par = ("d","e","f");
@t = (koitoutf8("Ethernet"), koitoutf8("WiFi"), koitoutf8("Внешний IP"));

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
my @t = (koitoutf8("Blacklist"), koitoutf8("Анти-TOR"), koitoutf8("Логи прокси"));

print "<br>";
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("Контроль за интернетом")."</div>";
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
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("Веб-камеры")."</div>";
print "<br>";

@par = ("k","l","m");
@t = (koitoutf8("Live Stream"), koitoutf8("Запись видео+аудио"), koitoutf8("Распознавание объектов"));

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
my @t = (koitoutf8("Почта"), koitoutf8("Прокси"), koitoutf8("FTP, HTTP, FILE"), koitoutf8("База данных"));

print "<br>";
print "<div style=\"padding:15px $pr 0px $pl;color:#9cf;font-weight:bold;font-size:16px;\">".koitoutf8("Офисный софтпак")."</div>";
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

print "<div style=\"margin-left:$ml;margin-top:22px;padding:10px 25px;color:#9cf;line-height:20px;background:#567086;font-size:14px;width:190px;border-radius:20px;\">".koitoutf8("Эксклюзивная подписка<br>на <span style='color:#fed;text-decoration:underline;'>офисный софтпак</span><span style='font-style:italic;color:963;font-size:24px;'>&nbsp;!..</span><br>всего за <span style='color:#fed;'>19990 руб.</span>").
"</div>";
print "</div>";
print qq{<div style="clear:left;"><div>};
print "<br>";
print "<br>";
print qq{</body></html>};
exit;

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
