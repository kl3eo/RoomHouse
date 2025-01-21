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
	my $texta_stage3 = koitoutf8("�������� � ������������ �������� ����������:");
	my $textb_stage3 = koitoutf8("SSL �� �������!<br>�������� ����� <span class=blu>HTTPS</span> � ���� ���������<br>� ������� ������<div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");

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
	
	
	my $texta_stage3 = koitoutf8("����������� ������ ��������! ����� ������� �������� ��� ����������� ������.");
	my $textb_stage3 = koitoutf8("������� �� Windows � ����� ���������� �����.<div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");

	print qq{<div class=inw>

			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage3</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage3</div>		
		</div>

	};
	
} else {
	my $ret = `find /opt/nvme/ssd/shared -maxdepth 1 -type f -printf "\%f\n"`; my @l = split('\n', $ret);
	my $texta_stage3 = koitoutf8("����� ������ � Windows �� ����� Z:");
	my $text_stage2 =  koitoutf8("��������� ����");	
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
