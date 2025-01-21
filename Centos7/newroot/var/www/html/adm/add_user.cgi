#!/usr/bin/perl
#use 5.006;
use CGI;
use MIME::Base64;

my $query = new CGI;
#print $query->header(-charset=>'koi8-r');

my $scriptname = "add_user.cgi";

my $admmode = defined($query->param('admmode')) ? $query->param('admmode') : '';
 
unless ($admmode eq "add_user") {

print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">};
print qq{<html><head><title>Local users add script</title>};

print qq{
<script language="JavaScript" type="text/javascript" src="/js/mootools-core-1.3-full-compat-yc.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/mootools-more.js"></script>
<script>

// Create Base64 Object

var Base64={_keyStr:'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',encode:function(e){var t='';var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t='';var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9\+\/\=]/g,'');while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){var t='';for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t='';var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}

	function do_add_user(u,p) {
		var form = document.createElement("form");
		form.setAttribute("method", "get");
		form.setAttribute("id", "myForm");

		document.body.appendChild(form);

		u=Base64.encode(u);
		p=Base64.encode(p); 

		\$('myForm').action = '/?mode=uc_add_user&admmode=add_user&u='+u+'&p='+p;

		\$('myForm').send();
		\$('myForm').dispose();
		alert('please wait..READY ');
		location.href='/?mode=uc_add_user';
	}

	</script>
};

print qq{</head><body style="background:#ddd;padding:20px;">};

print qq{
<div style="width:72px;text-align:center;margin:50px auto 10px auto;background:#ccc;position:relative;">
	<div id=container style="font-size:14px;width:72px;">
                <div style="width:60px;">
			<input id=u type=text VALUE="user" onmousedown="this.value='';">
		</div>
                <div style="width:60px;">
			<input id=p type=text VALUE="pass" onmousedown="this.value='';">
		</div>
	</div>
	<div style="margin-top:20px;font-size:14px;">
		<INPUT TYPE=button onClick="var yon = window.confirm('Add user '+\$('u').value+'?');if (yon) {do_add_user(\$('u').value,\$('p').value);}" VALUE="Добавить">
	</div>
</div>	

};

print "Active LAN USERS:<br><br>";


open (IN, '-|', "cat /etc/passwd")
	or die ("Can't find file to read from!");


	
while (!eof(IN)) {
	my $q = readline (*IN);	
	(my @who) = split(':',$q);
	print $who[0]."<br>" if ( int($who[2]) > 1002 );

}

close (IN);

print qq{<br><br>
</body></html>};

} else {

my $u = $query->param('u');
my $p = $query->param('p');

$u = MIME::Base64::decode_base64($u);
$p = MIME::Base64::decode_base64($p);

		system("/usr/bin/sudo /usr/local/bin/add_user.sh $u $p");
		print STDERR "Just added user $u with password $p!\n";
}

exit;
