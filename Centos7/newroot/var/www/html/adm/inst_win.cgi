#!/usr/bin/perl

use CGI;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw(gettimeofday);

my %Cookies = GetCookies('LANG','ScreenResW');
my $srw = defined($Cookies{'ScreenResW'}) ? $Cookies{'ScreenResW'} : 1280;

my $ajval = 5000; #3sec
my $browser=$ENV{'HTTP_USER_AGENT'};
my $my_ip = $ENV{SERVER_NAME};
my $touch_specific_bro = 0;

$touch_specific_bro = 1 if ( $browser=~/Silk/ || $browser=~/iPhone/ || $browser=~/iPad/ || $browser=~/Android/ || $browser=~/Mobile/);
$touch_specific_bro = ($srw <= 1024) ? 1 : $touch_specific_bro;

my $query = new CGI;

my $u = $query->param('u');$u = MIME::Base64::decode_base64($u);
my $wsize = defined( $query->param('ws') ) ? $query->param('ws') : 36;

my $admmode = defined($query->param('admmode')) ? $query->param('admmode') : '';
my $ret = defined($query->param('ret')) ? $query->param('ret') : 0;

print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">};
print qq{<html><head><title>Local Windows Install</title>};

my $maxdrive = `df | grep "/opt/nvme/ssd" | awk '{print int((\$4/(1024*1024)) * 0.9)}'`; $maxdrive =~ s/(\r|\n)//g;
my $warn1 = koitoutf8("������� �����! ��������� �������� 25...$maxdrive Gb");
my $warn2 = koitoutf8("���������� � ������� ����� ������������!");

	
my $current_use = 0;
	
if (-f "/opt/nvme/ssd/vm.img") {
	my $s = `ls -la /opt/nvme/ssd/vm.img | awk '{print \$5/(1024*1024*1024)}'`; $s =~ s/(\r|\n)//g;
	$current_use = int(($s/$wsize) * 100);
}
	
print qq{
<script language="JavaScript" type="text/javascript" src="/js/mootools-core-1.3-full-compat-yc.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/mootools-more.js"></script>

<script>

var ws = 36;
var step = 0;
var c_u = $current_use;

var Base64={_keyStr:'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',encode:function(e){var t='';var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t='';var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9\+\/\=]/g,'');while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){var t='';for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t='';var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}


	function do_inst_stage(u,r,wp,wss) {

		u=Base64.encode(u);
		wp=Base64.encode(wp);
		location.href='/?mode=uc_inst_win&admmode=next_stage&ret='+r+'&u='+u+'&wp='+wp+'&ws='+wss;
	}

	function validate_is_ws_less_or_equal(a,b){

  		var z = \$('ws').value;

  		if ( !/^[0-9]+\$/.test(z) || !(z >= a && z <= b) ) {
    			alert('$warn1');return false;
  		}
		return true;

	}
	function validate_is_good_pass(){

  		var z = \$('wp').value;

  		if ( z == '??') {
    			alert('$warn2');return false;
  		}
		return true;
	}

	function sendForm1() {
				
		if (\$('myForm1')) \$('myForm1').dispose();
		var form1 = document.createElement("form");
		form1.setAttribute("method", "get");
		form1.setAttribute("id", "myForm1");
		document.body.appendChild(form1);
		\$('myForm1').action = '/cgi/ru/check_formatting.pl?size='+ws;

		\$('myForm1').set('send', {
			onComplete: function(response) {

				if (response && response >= 100) {	

					var log = \$('log_percent_formatted').empty();
					log.set('html', response);
					(function(){\$('formatting').setStyles({'display': 'none'});\$('finished').setStyles({'display': 'table-cell'});}).delay(1000);

				}
				
				if (response && response < 100) {	

					var log = \$('log_percent_formatted').empty();
					log.set('html', response);
					to_set = setTimeout(sendForm1,$ajval);	
				}

				//console.log('step '+ step +', response ' + response);
				++step;
			}
		});

		\$('myForm1').send();
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


print qq{
<script>
if (!c_u) to_set = setTimeout('location.reload()',$ajval);
window.addEvent('domready', function(){
	ws = $wsize;
	sendForm1();	
});
</script>
} if ($u eq "stage3");

print qq{</head><body style="background:#435c70;"><div class=outw>};


my $scriptURL = CGI::url();

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

if ( length($wstate) ) {
my $texta_stage1 = koitoutf8("����������� ������ ��� ��������! �� ������ ������ ��� �����������?");
$scriptURL =~ s/https/vnc/g;$scriptURL =~ s/(\/)$//g;
my $textb_stage1 = koitoutf8("����� VNC-����������: <a href=$scriptURL:5900><span class=blu>$scriptURL:5900</span></a>");

print qq{
<div class=inw style="width:510px;">

	<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage1</div>
	<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage1</div>
</div>	
};
print qq{</div>
</body></html>};

exit;
}

unless ( $admmode eq "next_stage" ) {

my $texta_stage1 = koitoutf8("<h2>����� ����������</h2> � ��������� ��������� ���������� ����� Windows10 � ����������� xETR!");
my $textb_stage1 = koitoutf8("�������� � ������������ �������� ����������:");
my $c = '';
my $safe  = ($scriptURL =~ /^https:/) ? 1 : 0;
unless ($safe) {$c = " class=blink"}

my $col = $safe ? "#9cf" : "#f00";
my $textc_stage1 = $safe ? koitoutf8("SSL ������� - ����� ��������� ������") : koitoutf8("SSL �� �������!<br>�������� ����� <span class=blu>HTTPS</span> � ���� ���������<br>� ������� ������");
my $d = $safe ? '' : "display:none;";
print qq{
<div class=inw style="width:510px;">
	<div id=container style="display:none;">
		<input id=u type=text VALUE="stage2">
	</div>
	<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage1</div>
	<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage1</div>
	<div style="color:$col"$c>$scriptURL</div>
	<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textc_stage1</div>
	<div style="font-size:14px;margin:0 auto;text-align:center;width:100%;$d">
		<INPUT style="margin:20px auto;" TYPE=button onClick="var yon = window.confirm('Go to '+\$('u').value+'?');if (yon) {do_inst_stage(\$('u').value,0,'dummy',36);}" VALUE="Proceed with Install">
	</div>
</div>	

};


} else { #next_stage

my $wp = $query->param('wp');
my $wp_ext = MIME::Base64::decode_base64($wp);

if ($u eq "stage2") {
	$ret = `/usr/bin/sudo /usr/local/bin/mount_sdb.sh`;
	$ret =~ s/(\r|\n)//g;

	my $fsize = 0;
	
	if ($ret eq '2' || $ret eq '0') {

		$fsize = `ls -la /mnt/sdb/win.iso  | awk '{print \$5}'`;
		$ret = 'b' if ($fsize > 0);
		
	}

	if (($ret eq '1' || $ret eq '0') && $fsize eq '0') {

		$fsize = `ls -la /mnt/sda/win.iso  | awk '{print \$5}'`;
		$ret = 'a' if ($fsize > 0);
		
	}
	my $ultravnc = $touch_specific_bro ? "bVNC" : "TigerVNC";
	
	my $text_stage2 = $fsize > 4500000000 ? koitoutf8("���������� ������������:"): '';
	my $text_stage2a = $fsize > 4500000000 ? koitoutf8("Windows ������,Gb:"): '';
	my $texta_stage2 = $fsize > 0 ? koitoutf8("������ ISO-����� Windows:<br><span class=blu>$fsize</span> ����") : koitoutf8("���� ISO Windows �� ������ ��� �����������");
	my $textb_stage2 = $fsize > 4500000000 ? koitoutf8("��� ������ ��������� VNC-����� � ���������� TLS, ��������, <span class=blu>$ultravnc</span> ��� �����������") : koitoutf8("��������, ���� Windows ISO ��� ��������� ��� ������<div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");
	
	my $dspl = $fsize > 4500000000 ? "block" : "none";
	my $d = $fsize > 4500000000 ? '' : "display:none;";
	my $textd_stage2 = $fsize > 4500000000 ? koitoutf8("��������� ��� ������ �������� VNC-�����") : '';
	print qq{
		<div class=inw style="width:510px;">
			<div id=container style="display:none;">
				<input id=u type=text VALUE="stage3">
			</div>
			<div>
				<div style="float:left;width:50%;">
					<div style="color:#fee;margin:5px auto;font-size:16px;width:50%;">$text_stage2</div>
					<div id=container_wp style="display:$dspl;">
						<input id=wp type=password VALUE="??" style="width:70%;" onclick="this.value=''">
					</div>
				</div>
				<div style="float:left;width:50%;">
					<div style="color:#fee;margin:5px auto;font-size:16px;width:50%;">$text_stage2a</div>
					<div id=container_ws style="display:$dspl;">
						<input id=ws type=text VALUE="max $maxdrive" style="width:30%;" onclick="this.value=''">
					</div>
				</div>
				<div style="clear:left;width:0%;"></div>
			</div>			
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$texta_stage2</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textb_stage2</div>
			<div style="color:#fee;margin:5px auto;font-size:16px;width:70%;">$textd_stage2</div>
			<div style="font-size:14px;margin:0 auto;text-align:center;width:100%;$d">
				<INPUT style="margin:20px auto;" TYPE=button onClick="var yon = window.confirm('Go to '+\$('u').value+'?');if ( yon && validate_is_ws_less_or_equal(25,$maxdrive) && validate_is_good_pass()) { do_inst_stage(\$('u').value,'$ret',\$('wp').value,\$('ws').value );}" VALUE="Proceed with Install">
			</div>
		</div>
	};
}

if ($u eq "stage3") {

	my $ip_addr=$ENV{'REMOTE_ADDR'};
	my $pass = substr(md5_hex(gettimeofday()),16,8);
		
	my $text_stage3 = koitoutf8("��������� ��������<br>������� ������ Windows �������� $wsize Gb:");
	
	print qq{<div class=inw id=formatting style="width:510px;display:table-cell;">

			<div style="color:#fee;font-size:16px;width:100%;">$text_stage3</div>
			<div id=percent_formatted style="color:#fee;font-size:16px;width:100%;"><span id=log_percent_formatted>$current_use</span>%</div>

		</div>
	};

	my $text_stage3 = koitoutf8("��� ������������ Windows (��������!): <span class=blu>$wp_ext</span>");
	
	$pass = length($wpass) ? $wpass : $pass;
	
	$pass = substr($pass,0,8) if (length($pass) > 8);
	
	my $texta_stage3 = koitoutf8("����������� ������ ��� VNC: <span class=blu>$pass</span>");
	$scriptURL =~ s/https/vnc/g;$scriptURL =~ s/(\/)$//g;
	my $textb_stage3 = koitoutf8("����� VNC-����������:<br> <a href=$scriptURL:5900><span class=blu>$scriptURL:5900</span></a><div style=\"font-size:48px;cursor:pointer;color:#9cf;\" onclick=\"location.href='/?mode=uc_panel&part=2';\">&#8734;</div>");
	
	print qq{<div class=inw id=finished style="width:510px;display:none;">

			<div style="color:#fee;font-size:16px;width:100%;">$text_stage3</div>
			<div style="color:#fee;font-size:16px;width:100%;">$texta_stage3</div>
			<div style="color:#fee;font-size:16px;width:100%;">$textb_stage3</div>
		</div>
	};

	unless (-f "/opt/nvme/iso/virtio_w10_64.iso" && (-s "/opt/nvme/iso/virtio_w10_64.iso") > 1000000 ) {
		my $aret = `wget http://82.146.44.218/iso/virtio_w10_64.iso -O /opt/nvme/iso/virtio_w10_64.iso`;
	}
	
	
	my $nret = `/usr/bin/nohup /usr/bin/sudo /usr/local/bin/create_qemu.sh $ret $ip_addr $pass $wsize $wp $my_ip 2>&1 &` unless ($current_use);
}

print STDERR "Just jumped to $u!\n";
}


print qq{</div>
</body></html>};

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
