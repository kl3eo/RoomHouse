#!/usr/bin/perl

use CGI;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw(gettimeofday);

my $query = new CGI;
my $run = defined($query->param('run')) ? $query->param('run') : 0 ;

my $admmode = defined($query->param('admmode')) ? $query->param('admmode') : '';
my $ret = defined($query->param('ret')) ? $query->param('ret') : 0;

my $scriptURL = CGI::url();

#see what happens with windows right now

my $winfile_exists = 0;
$winfile_exists = 1 if (-f "/opt/nvme/ssd/vm.img" && -s "/opt/nvme/ssd/vm.img" > 25000000000);

my $wstate = '';
my $wruns = 0;#not running
$wruns = `sudo /usr/local/bin/ps.sh | grep "qemu-system-x86_64 --enable-kvm -drive driver=raw,file=/opt/nvme/ssd/vm/win10.img" |  grep -v grep | awk '{print \$2}'`;$wruns =~ s/(\r|\n)//g;

#print STDERR "Here wruns is $wruns!\n";

$wstate = "running" if ($wruns =~ /^\d+$/ && $wruns > 0);


print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">};
print qq{<html><head><title>Local Windows Install</title>};

print qq{
<script language="JavaScript" type="text/javascript" src="/js/mootools-core-1.3-full-compat-yc.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/mootools-more.js"></script>
<script>
var Base64={_keyStr:'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',encode:function(e){var t='';var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t='';var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9\+\/\=]/g,'');while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){var t='';for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t='';var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}
	
	function do_files_stage(u) {

		u=Base64.encode(u);
		location.href='/cgi/ru/dl2.cgi?u='+u;
	}
	
	
</script>
<style>
.blink {
  animation: blinker 1s step-start infinite;
}

\@keyframes blinker {
  50% {
    opacity: 0;
  }
}
.outw {display:table;height:100%;}
.inw {display:table-cell;vertical-align:middle;width:100%;text-align:center;}
.blu {color:#9cf;}
</style>

};

print qq{</head><body style="background:#435c70;"><div class=outw>};

my $safe  = ($scriptURL =~ /^https:/) ? 1 : 0;

unless ($safe) {
	my $texta_stage3 = koitoutf8("убедимся в безопасности текущего соединения:");
	my $textb_stage3 = koitoutf8("SSL не включен!<br>Включите режим <span class=blu>HTTPS</span> в меню Настройки<br>и начните заново<div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");

	print qq{<div class=inw style="width:510px;">
			<div id=container style="display:none;">
				<input id=u type=text VALUE="stage1">
			</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage3</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage3</div>
		</div>
	};

	print qq{</div></body></html>};
} else {

unless ( $admmode eq "next_stage" ) {

if ($wstate eq "running" && 0) {
	
	
	my $texta_stage3 = koitoutf8("Виртуальная машина работает! Обмен файлами возможен при выключенной машине.");
	my $textb_stage3 = koitoutf8("Выйдите из Windows и затем скопируйте файлы.<div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");

	print qq{<div class=inw>

			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage3</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage3</div>		
		</div>

	};
	
} else {
	my $ret = `find /opt/nvme/ssd/shared -maxdepth 1 -type f -printf "\%f\n"`; my @l = split('\n', $ret);
	my $texta_stage3 = koitoutf8("Файлы обмена с Windows на диске Z:");
	my $text_stage2 =  koitoutf8("Загрузить файл");	
		print qq{
			<div class=inw style="width:510px;text-align:center;">
<form action="/cgi/ru/upl.cgi" method="post" enctype="multipart/form-data">

						
						<div id=u_file>
							<input type='file' name='uploaded_file' id='ufile' />
						</div>
						<br>

						<div id=container_submit>
							<input type="submit" name="Submit" value="$text_stage2" />
						</div>
				
				<div style="color:#fee;margin:5px auto;font-size:16px;">$texta_stage3</div>
		};
		
		foreach my $line (@l) {
			print qq{
				<div style="color:#9cf;margin:5px auto;font-size:14px;cursor:pointer;" onclick="do_files_stage('$line')" onmouseover="this.style.textDecoration='underline';" onmouseout="this.style.textDecoration='none';">$line</div>
			};
		}

		print qq{	
				<div style="font-size:48px;cursor:pointer;color:#9cf;" onclick="location.href='/?mode=uc_panel&part=2';">&#8734;</div>
			</form>
			</div>
			
		};

	

	
}



print qq{</div></body></html>};

} #next stage
else {

} #admmode
} #safe

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
