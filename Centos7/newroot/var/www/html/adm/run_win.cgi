#!/usr/bin/perl

use CGI;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw(gettimeofday);

my %Cookies = GetCookies('LANG','ScreenResW');
my $srw = defined($Cookies{'ScreenResW'}) ? $Cookies{'ScreenResW'} : 1280;

my $browser=$ENV{'HTTP_USER_AGENT'};
my $my_ip = $ENV{SERVER_NAME};
my $touch_specific_bro = 0;

$touch_specific_bro = 1 if ( $browser=~/Silk/ || $browser=~/iPhone/ || $browser=~/iPad/ || $browser=~/Android/ || $browser=~/Mobile/);
$touch_specific_bro = ($srw <= 1024) ? 1 : $touch_specific_bro;

my $query = new CGI;
my $run = defined($query->param('run')) ? $query->param('run') : 1 ;

my $admmode = defined($query->param('admmode')) ? $query->param('admmode') : '';

my $u = $query->param('u');$u = MIME::Base64::decode_base64($u);
my $wp = $query->param('wp');my $wp_ext = MIME::Base64::decode_base64($wp);

print STDERR "HERE u is $u, wp is $wp, wp_ext is $wp_ext!\n";

print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">};
print qq{<html><head><title>Local Windows Install</title>};

print qq{
<script language="JavaScript" type="text/javascript" src="/js/mootools-core-1.3-full-compat-yc.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/mootools-more.js"></script>
<script>

var Base64={_keyStr:'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',encode:function(e){var t='';var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t='';var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9\+\/\=]/g,'');while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){var t='';for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t='';var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}

function do_run_stage(u,r,wp) {

	u=Base64.encode(u);
	wp=Base64.encode(wp);
	location.href='/?mode=uc_run_win&admmode=next_stage&run='+r+'&u='+u+'&wp='+wp;
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


my $scriptURL = CGI::url();

#see what happens with windows right now

my $winfile_exists = 0;
$winfile_exists = 1 if (-f "/opt/nvme/ssd/vm.img" && -s "/opt/nvme/ssd/vm.img" > 25000000000);

my $wstate = '';
my $wruns = 0;#not running
$wruns = `sudo /usr/local/bin/ps.sh | grep "qemu-system-x86_64 --enable-kvm -drive driver=raw,file=/opt/nvme/ssd/vm/win10.img" |  grep -v grep | awk '{print \$2}'`;$wruns =~ s/(\r|\n)//g;

print STDERR "Here wruns is $wruns!\n";

$wstate = "running" if ($wruns =~ /^\d+$/ && $wruns > 0);

print STDERR "Here wstate is $wstate and winfile_exists is $winfile_exists!\n";

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

if ( $wstate eq '' && $winfile_exists) {
	
	my $text_stage2 = koitoutf8("������� ������������:");
	
	print qq{<div class=inw>
			<div id=container style="display:none;">
				<input id=u type=text VALUE="stage2">
			</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$text_stage2</div>
			<div id=container_wp style="display:block;">
				<input id=wp type=password VALUE="??" style="width:50%;" onclick="this.value=''">
			</div>
		};
	
	my $ultravnc = $touch_specific_bro ? "bVNC" : "TigerVNC";
	
	my $para = $run eq '0' ? "paranoid" : "������";
	
	my $text_stage3 = koitoutf8("��� $para ��������� VNC-����� � ���������� TLS, ��������, <span class=blu>$ultravnc</span> ��� �����������");


	print qq{
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$text_stage3</div>
			<div style="font-size:14px;margin:0 auto;text-align:center;width:100%;">
				<INPUT style="margin:20px auto;" TYPE=button onClick="var yon = window.confirm('Go to '+\$('u').value+'?');if ( yon ) { do_run_stage(\$('u').value,$run,\$('wp').value);}" VALUE="Start">
			</div>
		</div>
	};

	print qq{</div></body></html>};	
	
	#my $nret = `/usr/bin/sudo /usr/local/bin/create_go.sh $ip_addr $pass $run $my_ip &`;$nret =~ s/(\r|\n)//g;

	exit;
} elsif ($wstate eq "running") {
	
	
	my $texta_stage3 = koitoutf8("����������� ������ ��� ��������! �� ������ ������ ��� �����������?");
	$scriptURL =~ s/https/vnc/g;$scriptURL =~ s/(\/)$//g;
	my $textb_stage3 = koitoutf8("����� VNC-����������: <a href=$scriptURL:5900><span class=blu>$scriptURL:5900</span></a><div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");

	print qq{<div class=inw>
			<div id=container style="display:none;">
				<input id=u type=text VALUE="stage1">
			</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage3</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage3</div>
		</div>
	};

	print qq{</div></body></html>};
	

} elsif (!$winfile_exists) {
	
	
	my $texta_stage3 = koitoutf8("Windows ��� �� ���������� ��� ��� ������. �������������� Windows.<div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");

	print qq{<div class=inw>
			<div id=container style="display:none;">
				<input id=u type=text VALUE="stage1">
			</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage3</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage3</div>
		</div>
	};

	print qq{</div></body></html>};
	

}
} #admmode
else {

if ($u eq "stage2") {

	my $check = `sudo /usr/local/bin/check_sig.pl $wp_ext 0 2>&1`;
print STDERR "Here check is $check!\n";
	my $texta_stage3 = ''; my $textb_stage3 = '';
	
	my $ip_addr=$ENV{'REMOTE_ADDR'};
	my $pass = substr(md5_hex(gettimeofday()),16,8);
	
	unless (length($check)) {
		$texta_stage3 = koitoutf8("��� ����������� ������ ��� VNC-����������: <span class=blu>$pass</span>");
		$scriptURL =~ s/https/vnc/g;$scriptURL =~ s/(\/)$//g;my $vnc_url =  $scriptURL;
		$textb_stage3 = koitoutf8("����� VNC-����������: <a href=$vnc_url:5900><span class=blu>$vnc_url:5900</span></a><div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");

	} else {
		$texta_stage3 = koitoutf8("����������� ������ ������������.<div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");
		$textb_stage3 = '';	
	}
	

	print qq{<div class=inw style="width:510px;">
			<div id=container style="display:none;">
				<input id=u type=text VALUE="stage3">
			</div>

			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage3</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage3</div>
		</div>
	};

	print qq{</div></body></html>};	
	
print STDERR " here params are $ip_addr $pass $run $wp $my_ip !\n";
	
	my $nret = `/usr/bin/sudo /usr/local/bin/create_go.sh $ip_addr $pass $run $wp $my_ip 2>&1 &` unless (length($check));
	
	exit;
} #stage2

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

sub GetCookies {

     my @cookieList = @_;

     my $query = new CGI;

     my %Cookies;

     foreach my $name (@cookieList) {

          $Cookies{$name} = $query->cookie($name);
     }

     return %Cookies;
}
