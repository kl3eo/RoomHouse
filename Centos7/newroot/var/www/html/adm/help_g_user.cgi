#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;

print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<head><title>HELP</title></head><body style="background:#ddd;text-align:center;color:#333;">};

my $text = koitoutf8("Административный интерфейс");
my $texta = koitoutf8("<p>Вход в административный интерфейс (АИ) xETR возможен по трём адресам URL: a) внутренний адрес Ethernet-сети (http://192.168.0.102),
б) внутренний адрес WiFi-сети (http://192.168.56.254) и в) внешний IP-адрес вашего Интернет-канала. Все три варианта одинаково отображаются в браузере.
Для входа в АИ используйте логин \"admin\" и тот пароль, который мы вам сообщили.</p><p>Обращаем внимание, что вам необходимо изменить данный пароль в целях безопасности. 
Для этого используйте опцию \"Admin key\" в меню Настройки. <b>Важно: Для просмотра текущего значения пароля для АИ кликните на значок \"[!]\" - 
значение пароля всегда отличается от значения вводимого вами Admin key!</b> Никому не сообщайте ваш новый пароль от АИ, но запишите его в надёжном месте. 
NB: вы всегда сможете сбросить все свои настройки, включая новый Admin key, в меню Настройки/Reset to Factory.</p>
<!-- p>Убедитесь, что ваши пользователи WiFi готовы к перезагрузке NUC, и она не вызовет каких-то нареканий с их стороны, поскольку их работа будет прервана на несколько минут.</p -->
<p>Зайдите в административный интерфейс xETR - http://192.168.0.102, далее выберите меню <b>Настройки</b>, измените значение <b>Admin_Key</b>, нажмите Enter, <b>обязательно кликните на \"[!]\", 
запишите новый админ-пароль!!!</b> и затем выберите <b>Save&Reboot</b>. 
После перезагрузки NUC система будет обновлена с новым значением admin-пароля для АИ.</p>");

print qq{<div style="width:90%;margin:30px auto 0px auto;font-size:24px;text-align:left;padding:5px;">$text</div>};

print qq{<div style="width:90%;margin:10px auto;font-size:16px;text-align:left;padding:5px;">$texta</div>};

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

