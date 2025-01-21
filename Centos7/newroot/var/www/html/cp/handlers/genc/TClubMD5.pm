#    Copyright (c) 2002 Alan Raetz, Chico Digital Engineering
#    All Rights Reserved.
#    Alex Shevlakov 2006-2010 suited LoginMD5 for TClub

package TClubMD5;

use Digest::MD5 qw(md5_hex);
use DB_File;             # persistent hash database
use CGI;                 # cookie functions
use DBI;
use strict 'refs';

require Exporter;

my $scriptURL = CGI::url();

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw($scriptname $url_prefix 
$use_server $browser $vers $mobile $salt $utf
$primary_server $primary_port $primary_dbase $primary_user $primary_passwd 
$extra_admin $apache2 
$frozen_guys_string $bar_guys_string $pssoff_guys_string $trusted_guys_string 
$classes_split $secret $use_facebook_reg $redirect_ru_en $bf1 $bf2 $bf3 $bf_center $default_charset
$current_domain_prefix $current_domain_prefix2 $ru_com %region_labels $denga $eemail $num_sports %sport_labels %sport_icons $curr_sport 
$sport_and $second_floor $only_one_floor $opz $opf $tpz $tpf $hpz $hpf $develop $trusted_users $https $node_number
);

our $use_server = 2; # 0 - developer, >0 - internet
our $develop = 0; # do some developing

our $scriptname = "cp";
our $utf = 1;
our $apache2 = 1;
our $node_number = 1;

our $https = ($scriptURL =~ /^http:\/\/(.+)/) ? "http" : ($scriptURL =~ /^https:\/\/(.+)/) ? "https" : "other";

$scriptURL =~ /^$https:\/\/(.+)(\/|$)/;

my $dom = $1;

$develop = 12;
#$develop = 14 if ($dom =~ /uma24/);
#$develop = 15 if ($scriptURL =~ /rsi\./);#hack ash

my $softpac = 0; 
if (-f "/etc/sysconfig/softpac") {
	$softpac = `cat /etc/sysconfig/softpac`; $softpac =~ s/(\r|\n)//g;
}

$develop = 16 if ($softpac eq '7');#hack ash

my $xetr_name = $dom =~/(^|\.)xetr\./ ? " to xTER" : $dom =~/(^|\.)antitor\./ ? " to AntiTOR" : $dom =~/(^|\.|j)uma24\./ ? " to Juma" : '';

$scriptname = '' if ($develop == 12 || $develop >= 14);

#print STDERR "Here dom is $dom, develop is $develop!\n";

my $old_design = 0;

my $header_title = "Match Machine";
$header_title = "CONTROL PANEL" if ($develop == 12 || $develop >= 14);
$header_title = "MARKET PANEL" if ($develop == 14);

############### YOU MUST EDIT THESE!
#

our $salt = "trafalgarzanzibar";
our $primary_server	= "127.0.0.1"; #primary business is here
our $primary_port	= "5432";
our $primary_dbase  	= "cp";
our $primary_user  	= "postgres";
our $primary_passwd	= "xxxxxxxxxxxx";
our $trusted_guys_string = 'unrel';
our $secret = "xxx";
our $extra_admin = "me"; #ME
our $trusted_users = "unrel";

my $emerg = 0;

my $classes_split = 0;

our $url_prefix = "http://motivation.ru";

our $browser = our $vers = '';
our $ru_com = '';
our $current_domain_prefix = "tennismatchmachine";
our $current_domain_prefix2 = "motivation";

my %Cookies = GetCookies('LANG','LOCO','MOBILE','SPORT','SecondFloor','ScreenResW');
my $loco_coo = $Cookies{'LOCO'};

our $curr_sport = $Cookies{'SPORT'} ? $Cookies{'SPORT'}  : 0;

our $opz = $curr_sport.'_1.0'; our $opf = $curr_sport.'_1.5';our $tpz = $curr_sport.'_2.0';our $tpf = $curr_sport.'_2.';
our $hpz = $curr_sport.'_3.0'; our $hpf = $curr_sport.'_3.';

our $mobile = 0;

our $only_one_floor = 1; #second floor refurbished, gentlemen

our $second_floor = 0;

our $num_sports = 11;

our %sport_labels = ('-1'=>'Other','0'=>'Tennis',
				'1'=>'Badminton','2'=>'Table Tennis','3'=>'Squash','4'=>'Curling','5'=>'Bikes','6'=>'Judo','7'=>'Auction',
				'8'=>'Lessons','9'=>'Pools','10'=>'Abroad');
our %sport_icons = ('-1'=>'other44','0'=>'tenn44',
				'1'=>'badm44','2'=>'tabl44','3'=>'squa44','4'=>'kerl44','5'=>'motorcycle44','6'=>'judo44',
				'7'=>'auct44','8'=>'emblem-people','9'=>'emblem-people','10'=>'emblem-people');
				
our %region_labels = ('-1'=>'Other','0'=>'Center',
				'1'=>'West','2'=>'South-West',
				'3'=>'South','4'=>'South-East',
				'5'=>'East','6'=>'North-East',
			        '7'=>'North','8'=>'North-West');
				

our $denga = "\$";
our $eemail	= "alex\@motivation.ru";

$url_prefix ='' if ($develop == 12 || $develop >= 14);

our $sport_and = "(sport = '$curr_sport') and";

our $use_facebook_reg = 1;

our $bf1= "/img/butterfly1.gif";
our $bf2= "/img/butterfly2.gif";
our $bf3= "/img/butterfly3.gif";
our $bf_center = "/img/lily.gif";

our $default_charset = "utf-8";

my $toss_result = get_random(0);
my $changing = 1;
$changing = 0 if ((int($toss_result/3))*3 == $toss_result);
$changing = 2 if ((int(($toss_result+1)/3))*3 == $toss_result+1);

if ($changing eq '1' || $changing eq '2') {
$bf1= "/img/snowflake1.gif";
$bf2= "/img/snowflake1.gif";
$bf3= "/img/snowflake1.gif";
$bf_center = "/img/nytree.gif";
}

my $prefix = "/var/www/html/cp";

#hack sh
$pref_lang = "en";
$pref_lang = "ru" if ($develop >= 14 && $develop < 16);

#print STDERR "Here pref is $pref_lang!\n";

my $lang = ($Cookies{'LANG'} eq '' || !defined($Cookies{'LANG'})) ? $pref_lang : $Cookies{'LANG'};

my $location_name;

our $redirect_ru_en = 'ru'; #default

my $lmod = "TClub_LANG_".$lang;

eval "use $lmod";

my $uniqueString = 'hellohellohello'; 

my $cgis = '/cgi';

my $tennis_pict = "<img src=/icon/tclub_logo_206x270_8colors_transp2.gif alt=\"TClub\" width=206 height=270>";

my $logogif;

my $debug = 0;

my $cookie_timeout = '+1d'; # or '+12h' for 12 hours, etc.
$cookie_timeout = '+100d' if ($develop == 12 || $develop >= 14);

my $screen_timeout = 300;

my $user_agent=$ENV{'HTTP_USER_AGENT'};

my $ip_addr=$ENV{'REMOTE_ADDR'};

my $real_ip_addr = $ip_addr;

my $log_file = 'login.log';

my ($scriptURL,$userFile,$sessionFile,%vars,$varsRef,$message,$randomNumber);

my $passString = 'cdAuth';
my $userCookieName = 'wtUser';
my $vcookie = 'v';
my $acookie = 'A';

if(defined ($ENV{'HTTP_USER_AGENT'})){
 $browser=$ENV{'HTTP_USER_AGENT'};
 ($vers)=($browser=~/\/(\d+\.\d+)/);
 ($vers)=($browser=~/MSIE (\d+\.\d+)/) if ($browser =~ /MSIE/);
}

my $android = 0;
$android = 1 if ($browser=~/Android/i);

my $touch_specific_bro = 1 
if ( $browser=~/Silk/i || $browser=~/iPhone/i || $browser=~/iPad/i || $browser=~/Android/i || ($ie6) || $mobile )
;

my $ie = 0;
$ie = 1 if ($browser=~/msie/i);

my $ie6 = 0;
$ie6 = 1 if ($ie && ($vers<8.0));

my $ie8 = 0;
$ie8 = 1 if ($ie && ($vers>=8.0));

my $ie9 = 0;
$ie9 = 1 if ($ie && ($vers>=9.0));


sub login {

($scriptURL, $userFile, $sessionFile, $varsRef, $randomNumber, $fb_user_id, $fb_name, $fb_gender, $fb_email, $fb_city, $fb_city_id, $fb_country,$dev) = @_;

my $loco = "ru" if ($develop == 12 || $develop >= 14); #bye bye scriptname

my $user_database_full_path = $prefix.'/handlers/users.db';
$user_database_full_path = $prefix.'/handlers/users_uma24.db' if ($develop == 14);

#print STDERR "db is $user_database_full_path!\n";

     if ( $varsRef ) { %vars = %{ $varsRef }; }
  
     my $sessionID = md5_hex( $ip_addr . $randomNumber . $uniqueString );
     my $current_time = time(); # time returns number of seconds since 1970
     return ("guest","",$__73) if ($vars{mode} eq "new_register");
     
     my $seed_sessionFile = $prefix.'/handlers/seeds.db.'.$real_ip_addr;

## registration

     if ($vars{Submit} eq "GO!") {
	  if ($vars{password1} ne $vars{password2}) {
	  return ("guest","Bad_Register", $__69 );
	  } elsif ( $vars{password1} eq md5_hex($vars{user}) || !$vars{user} || !$vars{email}) {
 	  return ("guest","Bad_Register",$__70);
	  } elsif ( $vars{srnum} ne md5_hex($vars{scode})) {
	  return ("guest","Bad_Register",$__71);
	  } elsif ($vars{password1} && $vars{user} &&$vars{email}) {
	  
	     my $is_indb = getHashValue($user_database_full_path,$vars{user});
	     if ($is_indb ne '' ) { 
	       return ("guest","Bad_Register",$__72);
	     }
          
	     setHashValue($seed_sessionFile,$sessionID,$current_time);

	  return ("guest","Cont_Register", $sessionID, $vars{password1});
	  }
     }
   
     if ($vars{mode} eq $regbutton) {

     	my $screent = getHashValue($seed_sessionFile,$vars{session_id});

     	deleteHashValue($seed_sessionFile,$vars{session_id});

	#here user gets into users.db
	setHashValue($user_database_full_path, $vars{proj_code}, $vars{reg_passwd} . '||' . $vars{g_email});     
     
     	setHashValue($seed_sessionFile,$sessionID,$current_time);

     	return ("guest","Good_Register", $sessionID, $vars{reg_passwd}, $vars{proj_code}, $vars{g_email}, $vars{regcookie});
     }
	  
     my %Cookies = GetCookies($passString,$userCookieName);
     
     if ( $debug == 1 ) {
     
          while ( my($key,$val) = each( %Cookies ) ) {
          
               $message .= "cookie $key = $val<br>\n";
          }
     }

     my $savedPasswordHash = getPasswordHash($Cookies{$userCookieName});

     my $saved_IP_address  = get_IP_address($Cookies{$userCookieName});
     
     my $cookieString = md5_hex($ip_addr.$savedPasswordHash.$uniqueString);
     $cookieString = md5_hex($savedPasswordHash.$uniqueString);
     
     my $cond_auth =  0; 
     $cond_auth =  1 if (($saved_IP_address && $saved_IP_address eq $ip_addr) || $android);#google changing ip_addr

     if ( $savedPasswordHash && $Cookies{$passString} && $cond_auth  &&  $Cookies{$passString} eq $cookieString  ) {

          if ( $debug == 1 ) { 
           
                 $message .= "User cookie validated, allowing access.\n"; 
          }

          # good cookie, allow access
          return ($Cookies{$userCookieName},$message, "Good cookies"); 
     }
    
     my ($user,$passwordHash) = MD5_login();
     
     if ( $debug ) {
          $message .= "SAVED HASH: $cookieString<br>\n";
          $message .= "IP ADDR: $ip_addr<br>\n";
          $message .= "CGI variables:<br>\n";
          foreach my $v ( keys %vars ) { $message .= "$v = $vars{$v}\n<br>"; }
     }

     setCurrentUserIPAddress($user,$ip_addr);

     my $setCookieString = md5_hex($ip_addr.$passwordHash.$uniqueString);
     $setCookieString = md5_hex($passwordHash.$uniqueString);

     my @cookies = ($passString,$setCookieString,$userCookieName,$user);

     my $header = SetCookies(\@cookies,$cookie_timeout); 
     
     if ( $debug == 1 ) { $header .= $message; }

     return ($user,$header); # SUCCESS, w/cookie header

}


sub MD5_login {

     cleanSessionDatabase(); # remove entries older than current_time + $timeout

my $addr=$ENV{'REMOTE_ADDR'};
#my $ddositsuko = &ddos_check($scriptURL);

     my $sessionID = md5_hex( $ip_addr . $randomNumber . $uniqueString );

     my $ck_pass = 'Pass';
     my $ck_user = 'User';
     my $graph = 'Graph';
     
     my %Cookies = GetCookies($ck_pass,$ck_user,$graph);

     my $current_time = time(); # time returns number of seconds since 1970

     setHashValue($sessionFile, $sessionID, $current_time);

     if ( $vars{Submit} eq $__74 ) {

	logAttempt(\%vars,$current_time);

          if ( my $session = checkPassword() ) {
	   
	   logAttempt(\%vars,$current_time,1);

               return ($vars{user},$session); # return user name and session
          } 
	  
     } else {
	printPAForm($sessionID);
     }

exit;
}
####################  END OF MAIN PROGRAM  #######################

sub checkPassword {

     if ( !$vars{user} )     { errorExit($__90); }

     if ( !$vars{password} ) { errorExit($__91); }
     
if ( 1 ) {
#print STDERR "Here user is $vars{user}, pass is $vars{password}, session is $vars{session}, sessionfile is $sessionFile !\n";

     my $lock = ChicoDigitalLock->new('yes',$sessionFile,1) or 
     
                # unable to lock session semphore (although flock() is set to wait)
                errorExit("Authentication Server Busy, Please Try Again...");
                
     #my $screenTime = getHashValue($sessionFile, $vars{session}) or errorExit("Time Out",$lock);
     
     deleteHashValue($sessionFile,$vars{session})
     
                              or errorExit("can't delete hash value",$lock);

     $lock->release(); # release flock() on session file semaphore
}

     my $savedPasswordHash = getPasswordHash($vars{user});

     my $hashedPassSession = md5_hex($savedPasswordHash.$vars{session});

     if ( $debug ) {
          $message .= "using session ID = $vars{session}<br>\n";
          $message .= "Saved password hash for $vars{user} = $savedPasswordHash<br>\n";
          $message .= "Submitted password hash for $vars{user} = $vars{password}<br>\n";
          $message .= "hashed stored pass + session string = $hashedPassSession<br>\n";
          $message .= "hashed submitted pass + session string = $vars{hash}<br>\n";
     }
#print STDERR $message."\n";

     if ( $hashedPassSession ne $vars{hash} ) {

          errorExit($__83);

     } else {

          return $savedPasswordHash;
     }
}

sub printPAForm {

my ($sessionID) = @_;

my $Username = $__75;
my $Password = $__76;
my $Go = $__74;
my $Title = $__84;
my $Welcome = "Welcome";

my $qs = $ENV{'QUERY_STRING'};
#print STDERR "Here qs is $qs!\n";

my $i_coo = $develop == 15 && $qs =~ /mode=interprete\&/ ? "writeCookie('IQS', '$qs')" : '';

if (($develop == 14 && $dom =~/(^|\.)juma24\./) || $develop >= 14) {$Username = "Username"; $Password = "Password"; $Go = "Enter"; $Title = "Login Window";};

my $scrwstr = defined($Cookies{'ScreenResW'}) && length($Cookies{'ScreenResW'}) ? '' : "writeCookie('ScreenResW', screen.width);";

my $nav = $touch_specific_bro ? '' : "<div><nav class=\"navbar navbar-expand-xl\"></nav></div>";

print qq{
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Cache-Control" content="private, no-cache, no-store, must-revalidate, max-age=0, proxy-revalidate, s-maxage=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <meta http-equiv="Vary" content="*">
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>$Title</title>
    <!-- link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:400,700" -->
    <link rel="stylesheet" href="/css_cp/fontroboto.css">
    <!-- https://fonts.google.com/specimen/Open+Sans -->
    <link rel="stylesheet" href="/css_cp/fontawesome.min.css" />
    <!-- https://fontawesome.com/ -->
    <link rel="stylesheet" href="/css_cp/bootstrap.min.css" />
    <!-- https://getbootstrap.com/ -->
    <link rel="stylesheet" href="/css_cp/templatemo-style.css">
    <!--
	Product Admin CSS Template
	https://templatemo.com/tm-524-product-admin
	-->
<script>

function writeCookie(cname,value) {
var curCookie = escape(cname) + "=" + escape(value) +"; expires=Sat, 01-Jan-2033 00:00:01 GMT;SameSite=None;Secure;"
document.cookie = curCookie
}

function safe_add(x, y)
{
  var lsw = (x & 0xFFFF) + (y & 0xFFFF)
  var msw = (x >> 16) + (y >> 16) + (lsw >> 16)
  return (msw << 16) | (lsw & 0xFFFF)
}

function rol(num, cnt)
{
  return (num << cnt) | (num >>> (32 - cnt))
}

function cmn(q, a, b, x, s, t)
{
  return safe_add(rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b)
}
function ff(a, b, c, d, x, s, t)
{
  return cmn((b & c) | ((~b) & d), a, b, x, s, t)
}
function gg(a, b, c, d, x, s, t)
{
  return cmn((b & d) | (c & (~d)), a, b, x, s, t)
}
function hh(a, b, c, d, x, s, t)
{
  return cmn(b ^ c ^ d, a, b, x, s, t)
}
function ii(a, b, c, d, x, s, t)
{
  return cmn(c ^ (b | (~d)), a, b, x, s, t)
}

function coreMD5(x)
{
  var a =  1732584193
  var b = -271733879
  var c = -1732584194
  var d =  271733878

  for(i = 0; i < x.length; i += 16)
  {
    var olda = a
    var oldb = b
    var oldc = c
    var oldd = d

    a = ff(a, b, c, d, x[i+ 0], 7 , -680876936)
    d = ff(d, a, b, c, x[i+ 1], 12, -389564586)
    c = ff(c, d, a, b, x[i+ 2], 17,  606105819)
    b = ff(b, c, d, a, x[i+ 3], 22, -1044525330)
    a = ff(a, b, c, d, x[i+ 4], 7 , -176418897)
    d = ff(d, a, b, c, x[i+ 5], 12,  1200080426)
    c = ff(c, d, a, b, x[i+ 6], 17, -1473231341)
    b = ff(b, c, d, a, x[i+ 7], 22, -45705983)
    a = ff(a, b, c, d, x[i+ 8], 7 ,  1770035416)
    d = ff(d, a, b, c, x[i+ 9], 12, -1958414417)
    c = ff(c, d, a, b, x[i+10], 17, -42063)
    b = ff(b, c, d, a, x[i+11], 22, -1990404162)
    a = ff(a, b, c, d, x[i+12], 7 ,  1804603682)
    d = ff(d, a, b, c, x[i+13], 12, -40341101)
    c = ff(c, d, a, b, x[i+14], 17, -1502002290)
    b = ff(b, c, d, a, x[i+15], 22,  1236535329)

    a = gg(a, b, c, d, x[i+ 1], 5 , -165796510)
    d = gg(d, a, b, c, x[i+ 6], 9 , -1069501632)
    c = gg(c, d, a, b, x[i+11], 14,  643717713)
    b = gg(b, c, d, a, x[i+ 0], 20, -373897302)
    a = gg(a, b, c, d, x[i+ 5], 5 , -701558691)
    d = gg(d, a, b, c, x[i+10], 9 ,  38016083)
    c = gg(c, d, a, b, x[i+15], 14, -660478335)
    b = gg(b, c, d, a, x[i+ 4], 20, -405537848)
    a = gg(a, b, c, d, x[i+ 9], 5 ,  568446438)
    d = gg(d, a, b, c, x[i+14], 9 , -1019803690)
    c = gg(c, d, a, b, x[i+ 3], 14, -187363961)
    b = gg(b, c, d, a, x[i+ 8], 20,  1163531501)
    a = gg(a, b, c, d, x[i+13], 5 , -1444681467)
    d = gg(d, a, b, c, x[i+ 2], 9 , -51403784)
    c = gg(c, d, a, b, x[i+ 7], 14,  1735328473)
    b = gg(b, c, d, a, x[i+12], 20, -1926607734)

    a = hh(a, b, c, d, x[i+ 5], 4 , -378558)
    d = hh(d, a, b, c, x[i+ 8], 11, -2022574463)
    c = hh(c, d, a, b, x[i+11], 16,  1839030562)
    b = hh(b, c, d, a, x[i+14], 23, -35309556)
    a = hh(a, b, c, d, x[i+ 1], 4 , -1530992060)
    d = hh(d, a, b, c, x[i+ 4], 11,  1272893353)
    c = hh(c, d, a, b, x[i+ 7], 16, -155497632)
    b = hh(b, c, d, a, x[i+10], 23, -1094730640)
    a = hh(a, b, c, d, x[i+13], 4 ,  681279174)
    d = hh(d, a, b, c, x[i+ 0], 11, -358537222)
    c = hh(c, d, a, b, x[i+ 3], 16, -722521979)
    b = hh(b, c, d, a, x[i+ 6], 23,  76029189)
    a = hh(a, b, c, d, x[i+ 9], 4 , -640364487)
    d = hh(d, a, b, c, x[i+12], 11, -421815835)
    c = hh(c, d, a, b, x[i+15], 16,  530742520)
    b = hh(b, c, d, a, x[i+ 2], 23, -995338651)

    a = ii(a, b, c, d, x[i+ 0], 6 , -198630844)
    d = ii(d, a, b, c, x[i+ 7], 10,  1126891415)
    c = ii(c, d, a, b, x[i+14], 15, -1416354905)
    b = ii(b, c, d, a, x[i+ 5], 21, -57434055)
    a = ii(a, b, c, d, x[i+12], 6 ,  1700485571)
    d = ii(d, a, b, c, x[i+ 3], 10, -1894986606)
    c = ii(c, d, a, b, x[i+10], 15, -1051523)
    b = ii(b, c, d, a, x[i+ 1], 21, -2054922799)
    a = ii(a, b, c, d, x[i+ 8], 6 ,  1873313359)
    d = ii(d, a, b, c, x[i+15], 10, -30611744)
    c = ii(c, d, a, b, x[i+ 6], 15, -1560198380)
    b = ii(b, c, d, a, x[i+13], 21,  1309151649)
    a = ii(a, b, c, d, x[i+ 4], 6 , -145523070)
    d = ii(d, a, b, c, x[i+11], 10, -1120210379)
    c = ii(c, d, a, b, x[i+ 2], 15,  718787259)
    b = ii(b, c, d, a, x[i+ 9], 21, -343485551)

    a = safe_add(a, olda)
    b = safe_add(b, oldb)
    c = safe_add(c, oldc)
    d = safe_add(d, oldd)
  }
  return [a, b, c, d]
}

function binl2hex(binarray)
{
  var hex_tab = "0123456789abcdef"
  var str = ""
  for(var i = 0; i < binarray.length * 4; i++)
  {
    str += hex_tab.charAt((binarray[i>>2] >> ((i%4)*8+4)) & 0xF) +
           hex_tab.charAt((binarray[i>>2] >> ((i%4)*8)) & 0xF)
  }
  return str
}

function binl2b64(binarray)
{
  var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  var str = ""
  for(var i = 0; i < binarray.length * 32; i += 6)
  {
    str += tab.charAt(((binarray[i>>5] << (i%32)) & 0x3F) |
                      ((binarray[i>>5+1] >> (32-i%32)) & 0x3F))
  }
  return str
}

function str2binl(str)
{
  var nblk = ((str.length + 8) >> 6) + 1 // number of 16-word blocks
  var blks = new Array(nblk * 16)
  for(var i = 0; i < nblk * 16; i++) blks[i] = 0
  for(var i = 0; i < str.length; i++)
    blks[i>>2] |= (str.charCodeAt(i) & 0xFF) << ((i%4) * 8)
  blks[i>>2] |= 0x80 << ((i%4) * 8)
  blks[nblk*16-2] = str.length * 8
  return blks
}

function strw2binl(str)
{
  var nblk = ((str.length + 4) >> 5) + 1 // number of 16-word blocks
  var blks = new Array(nblk * 16)
  for(var i = 0; i < nblk * 16; i++) blks[i] = 0
  for(var i = 0; i < str.length; i++)
    blks[i>>1] |= str.charCodeAt(i) << ((i%2) * 16)
  blks[i>>1] |= 0x80 << ((i%2) * 16)
  blks[nblk*16-2] = str.length * 16
  return blks
}

/*
 * External interface
 */
function hexMD5 (str) { return binl2hex(coreMD5( str2binl(str))) }
function hexMD5w(str) { return binl2hex(coreMD5(strw2binl(str))) }
function b64MD5 (str) { return binl2b64(coreMD5( str2binl(str))) }
function b64MD5w(str) { return binl2b64(coreMD5(strw2binl(str))) }
/* Backward compatibility */
function calcMD5(str) { return binl2hex(coreMD5( str2binl(str))) }
$scrwstr
$i_coo
</script>
  </head>

  <body>
  $nav
    <div class="container tm-mt-big tm-mb-big" style="">
      <div class="row">
        <div class="col-12 mx-auto tm-login-col" style="display:table-cell;vertical-align:middle;">
          <div class="tm-bg-primary-dark tm-block tm-block-h-auto" style="margin:auto;height:450px;">
            <div class="row">
              <div class="col-12 text-center">
                <h2 class="tm-block-title mb-4">$Welcome$xetr_name!</h2>
              </div>
            </div>
            <div class="row mt-2">
              <div class="col-12">
                <!-- form action="index.html" method="post" class="tm-login-form" -->
		<form method="post" action="$scriptURL"  onsubmit="password.value=calcMD5(password.value+user.value); hash.value=calcMD5(password.value+session.value); return true">
                  <div class="form-group">
                    <label for="user">$Username</label>
                    <input
                      name="user"
                      type="text"
                      class="form-control validate"
                      id="user"
                      value=""
                      required
                    />
                  </div>
                  <div class="form-group mt-3">
                    <label for="password">$Password</label>
                    <input
                      name="password"
                      type="password"
                      class="form-control validate"
                      id="password"
                      value=""
                      required
                    />
                  </div>
                  <div class="form-group mt-4">
		  	<input type=hidden name=hash size=20 maxsize=80>
			<input type=hidden name=session value="$sessionID" size=40>
                    <button
                      name="Submit"
		      type="submit"
                      class="btn btn-primary btn-block text-uppercase"
		      value="$__74"
                    >
                      $Go
                    </button>
                  </div>
                  <!-- button class="mt-5 btn btn-primary btn-block text-uppercase">
                    Forgot your password?
                  </button -->
                </form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <footer class="tm-footer row tm-mt-small">
      <div class="col-12 font-weight-light">
        <p class="text-center text-white mb-0 px-4 small">
          Copyright &copy; xTER v1.42 <b>2008-2025</b>
          
          <!--span> Design: <a rel="nofollow noopener" href="https://templatemo.com" class="tm-footer-link">Template Mo</a> </span -->
        </p>
      </div>
    </footer>
    <script src="/js_cp/jquery-3.3.1.min.js"></script>
    <script src="/js_cp/bootstrap.min.js"></script>

  </body>
</html>

};

}

sub logAttempt {

     my ($varsRef,$time,$good) = @_;

     my ($seconds,$minutes,$hours,
                      $day,$month,$year) = localtime($time);

     $year += 1900; $month++;
     
     my $zero = '0' if ($hours < 10);

     my $timestamp =  sprintf("%4d %02d %02d",$year,$month,$day)
                      . ' ' .$zero. $hours . ':' . $minutes . ':' . $seconds;

     open(LOG, ">>$log_file") or errorExit("unable to open log file $log_file\n");

     print LOG $timestamp . ' >> ';

     foreach my $key ( keys %$varsRef ) {

          print LOG ' | ' . $key . "=" . $varsRef->{$key};
     }
	
	$user_agent =~ s/ /\_/g;
	print LOG ' | '. $real_ip_addr . ' | ' . $user_agent;
	print LOG ' | GOOD ATTEMPT' if $good;
     print LOG "\n";

     close(LOG);
}

sub errorExit {

     my ($msg,$lock,$cont) = @_;
     
     if ( $lock ) { $lock->release(); }

     print "Content-type: text/html; charset=".$default_charset."\n\n" unless ($cont);

print qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head><title>$header_title</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="Cache-Control" content="private, no-cache, no-store, must-revalidate, max-age=0, proxy-revalidate, s-maxage=0">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Vary" content="*">
</head><body>
};
print qq{
<div style="width:100%;background:transparent;text-align:center;margin-top:12%;">
<div style="text-align:center;margin:0 auto;width:480px;padding:10px;">
<div  style="margin:0px auto;width:240px;padding:5px;">

<span style="FONT-FAMILY:Verdana, Geneva, sans-serif;COLOR:#666;FONT-SIZE:24px;">$msg</span>

</div>
<div style="color:#222;FONT-FAMILY:Verdana, Geneva, sans-serif;COLOR:#666;FONT-SIZE:18px;margin:20px 0px;">
<a href="$scriptname?Submit=Logout">$__88</a>
</div>
</div>
</div>
};

print "</body></html>";

exit;
}

#############################################################################
# Hash Database Code
#############################################################################

sub getPasswordHash {

     my $name = shift;

     if ( ! $name ) { return undef; }

     my $userHash = getHashValue($userFile,$name);
     
     return (split(/\|\|/,$userHash))[0];
}

sub get_IP_address {

     my $name = shift;

     if ( ! $name ) { return undef; }

     my $userHash = getHashValue($userFile,$name);

     return (split(/\|\|/,$userHash))[2]; # fourth entry
}

sub setCurrentUserIPAddress {

     my ($userName,$ip_address) = @_;

     my $userHash = getHashValue($userFile,$userName);

     my ($hash,$email,$old_addr) = split(/\|\|/,$userHash);

     my $userEntry = $hash . '||' . $email . '||' . $ip_address;

     setHashValue($userFile,$userName,$userEntry);
}

sub getHashValue {

     my ($file,$name) = @_;

     my %hash;
     
     tie(%hash, 'DB_File', $file, O_RDWR, 0664, $DB_HASH) or return undef;
 
     my $value = $hash{$name} || '';

     untie(%hash) or return undef;

     return $value;
}


sub setHashValue {

     my ($file,$key,$value) = @_;

     my %hash;

     tie(%hash, 'DB_File', $file, O_CREAT|O_RDWR, 0664, $DB_HASH) 
     
           or errorExit("can't tie hash value");

     $hash{$key} = $value;

     untie(%hash) or errorExit("can't untie hash value");
}

sub deleteHashValue {

     my ($file,$key) = @_;

     my %hash;

     tie(%hash, 'DB_File', $file, O_RDWR, 0664, $DB_HASH)

           or return undef; 
           
     delete $hash{$key};

     untie(%hash) or return undef;
     
     return 1; # success
}

sub cleanSessionDatabase {

     my %hash;

     if ( $debug ) { $message .= "\nCurrent time = " . time() . "<br>\n"; }

     tie(%hash, 'DB_File', $sessionFile, O_RDWR|O_CREAT, 0644, $DB_HASH) 

or errorExit("Temporarily out of service || $__99a\n");

     foreach my $key ( keys %hash ) {

          my $displayTime = $hash{$key};

          if ( ($displayTime + $screen_timeout) < time()  ) {

               if ( $debug ) {
                    $message .= "\nClearing session " . $key . " = " . $displayTime . "<br>\n"; 
               }

               delete($hash{$key});
          }
     }

     untie(%hash) or errorExit("Unable to close hash file\n");
}



#############################################################################
# Cookies Code
#############################################################################

sub ClearAllCookies {

     $scriptURL = shift;
     $norepeat = shift;

     print ClearCookies($passString,$userCookieName,$vcookie,$acookie);

     print "<HTML><HEAD><TITLE>Bye</TITLE>";
     print "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=".$default_charset."\">";
     print q{<meta name="viewport" content="width=device-width, initial-scale=0.9">
         <meta http-equiv="Cache-Control" content="private, no-cache, no-store, must-revalidate, max-age=0, proxy-revalidate, s-maxage=0">
         <meta http-equiv="Pragma" content="no-cache">
         <meta http-equiv="Expires" content="0">
         <meta http-equiv="Vary" content="*">
     };
     
     print qq{
     <script>
/*
     	function writeCookie(cname,value) {
		var curCookie = escape(cname) + "=" + escape(value) +"; expires=Thu, 01-Jan-1970 00:00:01 GMT;SameSite=None;Secure;"
		document.cookie = curCookie
	}
	writeCookie('v',0);
	writeCookie('A',0);
*/
/*
     sessionStorage.clear()

     localStorage.clear()

     caches.keys().then(keys => {
       keys.forEach(key => caches.delete(key))
     })

     indexedDB.databases().then(dbs => {
       dbs.forEach(db => indexedDB.deleteDatabase(db.name))
     })
*/

	var cookies = document.cookie.split(";");

	for (var i = 0; i < cookies.length; i++) {
		var cookie = cookies[i];
		var eqPos = cookie.indexOf("=");
		var coo_name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
		while (coo_name.charAt(0)==' ') coo_name = coo_name.substring(1,coo_name.length);

		document.cookie = coo_name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=None; Secure;";
	}

     </script>
     };
     print qq{
     <script>
     function off () {
     location.href='$scriptURL'+'?mode=login'
     }
     setTimeout('off()',500);
     </script>
     } unless ($norepeat);
     print "</HEAD><BODY>\n";


print qq{
<div style="width:100%;background:transparent;text-align:center;margin-top:15%;">
<div style="text-align:center;margin:0 auto;width:100%;padding:10px;">
<div  style="margin:0px auto;width:50%;padding:5px;">
<img src="/icon/spinning-wheel3.gif" width="60">
</div>
<div style="color:#222;FONT-FAMILY:Verdana, Geneva, sans-serif;COLOR:#666;FONT-SIZE:18px;margin:20px 0px;">
<span style="FONT-FAMILY:Verdana, Geneva, sans-serif;COLOR:#666;FONT-SIZE:24px;">$__89</span>
</div>
</div>
</div>
};
     print "</BODY></HTML>";
     exit;

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

sub ClearCookies {

     my @cookies;

     foreach my $entry ( @_ ) { 

         push(@cookies,$entry);
         push(@cookies,'x');
     }

     return SetCookies([@cookies],'+0s');
}

sub SetCookies {

     my ($cookieRef,$expires) = @_;

     my @Cookie_objects;

     my $query = new CGI;

     while ( my ($cookie,$value) = shift2($cookieRef) ) {

          push(@Cookie_objects, makeCookie($query,$cookie,$value,$expires));

     }

     return $query->header(-type=> 'text/html;charset='.$default_charset,-cookie=>[@Cookie_objects]);
}

sub shift2 { return splice( @{$_[0]}, 0, 2 ); }

sub makeCookie {

     my ($query,$cookie,$value,$expires) = @_;

     return $query->cookie(-name=>$cookie,
                           -value=>$value,
                           -expires=>$expires,
			   -samesite=>,'None',
			   -secure=>1,
                           -path=>'/',
                           );
}


sub print_javascript_md5 {

print<<END_OF_JAVASCRIPT; 
/*
 * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
 * Digest Algorithm, as defined in RFC 1321.
 * Version 1.1 Copyright (C) Paul Johnston 1999 - 2002.
 * Code also contributed by Greg Holt
 * See http://pajhome.org.uk/site/legal.html for details.
 */

/*
 * Add integers, wrapping at 2^32. This uses 16-bit operations internally
 * to work around bugs in some JS interpreters.
 */
function safe_add(x, y)
{
  var lsw = (x & 0xFFFF) + (y & 0xFFFF)
  var msw = (x >> 16) + (y >> 16) + (lsw >> 16)
  return (msw << 16) | (lsw & 0xFFFF)
}

/*
 * Bitwise rotate a 32-bit number to the left.
 */
function rol(num, cnt)
{
  return (num << cnt) | (num >>> (32 - cnt))
}

/*
 * These functions implement the four basic operations the algorithm uses.
 */
function cmn(q, a, b, x, s, t)
{
  return safe_add(rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b)
}
function ff(a, b, c, d, x, s, t)
{
  return cmn((b & c) | ((~b) & d), a, b, x, s, t)
}
function gg(a, b, c, d, x, s, t)
{
  return cmn((b & d) | (c & (~d)), a, b, x, s, t)
}
function hh(a, b, c, d, x, s, t)
{
  return cmn(b ^ c ^ d, a, b, x, s, t)
}
function ii(a, b, c, d, x, s, t)
{
  return cmn(c ^ (b | (~d)), a, b, x, s, t)
}

/*
 * Calculate the MD5 of an array of little-endian words, producing an array
 * of little-endian words.
 */
function coreMD5(x)
{
  var a =  1732584193
  var b = -271733879
  var c = -1732584194
  var d =  271733878

  for(i = 0; i < x.length; i += 16)
  {
    var olda = a
    var oldb = b
    var oldc = c
    var oldd = d

    a = ff(a, b, c, d, x[i+ 0], 7 , -680876936)
    d = ff(d, a, b, c, x[i+ 1], 12, -389564586)
    c = ff(c, d, a, b, x[i+ 2], 17,  606105819)
    b = ff(b, c, d, a, x[i+ 3], 22, -1044525330)
    a = ff(a, b, c, d, x[i+ 4], 7 , -176418897)
    d = ff(d, a, b, c, x[i+ 5], 12,  1200080426)
    c = ff(c, d, a, b, x[i+ 6], 17, -1473231341)
    b = ff(b, c, d, a, x[i+ 7], 22, -45705983)
    a = ff(a, b, c, d, x[i+ 8], 7 ,  1770035416)
    d = ff(d, a, b, c, x[i+ 9], 12, -1958414417)
    c = ff(c, d, a, b, x[i+10], 17, -42063)
    b = ff(b, c, d, a, x[i+11], 22, -1990404162)
    a = ff(a, b, c, d, x[i+12], 7 ,  1804603682)
    d = ff(d, a, b, c, x[i+13], 12, -40341101)
    c = ff(c, d, a, b, x[i+14], 17, -1502002290)
    b = ff(b, c, d, a, x[i+15], 22,  1236535329)

    a = gg(a, b, c, d, x[i+ 1], 5 , -165796510)
    d = gg(d, a, b, c, x[i+ 6], 9 , -1069501632)
    c = gg(c, d, a, b, x[i+11], 14,  643717713)
    b = gg(b, c, d, a, x[i+ 0], 20, -373897302)
    a = gg(a, b, c, d, x[i+ 5], 5 , -701558691)
    d = gg(d, a, b, c, x[i+10], 9 ,  38016083)
    c = gg(c, d, a, b, x[i+15], 14, -660478335)
    b = gg(b, c, d, a, x[i+ 4], 20, -405537848)
    a = gg(a, b, c, d, x[i+ 9], 5 ,  568446438)
    d = gg(d, a, b, c, x[i+14], 9 , -1019803690)
    c = gg(c, d, a, b, x[i+ 3], 14, -187363961)
    b = gg(b, c, d, a, x[i+ 8], 20,  1163531501)
    a = gg(a, b, c, d, x[i+13], 5 , -1444681467)
    d = gg(d, a, b, c, x[i+ 2], 9 , -51403784)
    c = gg(c, d, a, b, x[i+ 7], 14,  1735328473)
    b = gg(b, c, d, a, x[i+12], 20, -1926607734)

    a = hh(a, b, c, d, x[i+ 5], 4 , -378558)
    d = hh(d, a, b, c, x[i+ 8], 11, -2022574463)
    c = hh(c, d, a, b, x[i+11], 16,  1839030562)
    b = hh(b, c, d, a, x[i+14], 23, -35309556)
    a = hh(a, b, c, d, x[i+ 1], 4 , -1530992060)
    d = hh(d, a, b, c, x[i+ 4], 11,  1272893353)
    c = hh(c, d, a, b, x[i+ 7], 16, -155497632)
    b = hh(b, c, d, a, x[i+10], 23, -1094730640)
    a = hh(a, b, c, d, x[i+13], 4 ,  681279174)
    d = hh(d, a, b, c, x[i+ 0], 11, -358537222)
    c = hh(c, d, a, b, x[i+ 3], 16, -722521979)
    b = hh(b, c, d, a, x[i+ 6], 23,  76029189)
    a = hh(a, b, c, d, x[i+ 9], 4 , -640364487)
    d = hh(d, a, b, c, x[i+12], 11, -421815835)
    c = hh(c, d, a, b, x[i+15], 16,  530742520)
    b = hh(b, c, d, a, x[i+ 2], 23, -995338651)

    a = ii(a, b, c, d, x[i+ 0], 6 , -198630844)
    d = ii(d, a, b, c, x[i+ 7], 10,  1126891415)
    c = ii(c, d, a, b, x[i+14], 15, -1416354905)
    b = ii(b, c, d, a, x[i+ 5], 21, -57434055)
    a = ii(a, b, c, d, x[i+12], 6 ,  1700485571)
    d = ii(d, a, b, c, x[i+ 3], 10, -1894986606)
    c = ii(c, d, a, b, x[i+10], 15, -1051523)
    b = ii(b, c, d, a, x[i+ 1], 21, -2054922799)
    a = ii(a, b, c, d, x[i+ 8], 6 ,  1873313359)
    d = ii(d, a, b, c, x[i+15], 10, -30611744)
    c = ii(c, d, a, b, x[i+ 6], 15, -1560198380)
    b = ii(b, c, d, a, x[i+13], 21,  1309151649)
    a = ii(a, b, c, d, x[i+ 4], 6 , -145523070)
    d = ii(d, a, b, c, x[i+11], 10, -1120210379)
    c = ii(c, d, a, b, x[i+ 2], 15,  718787259)
    b = ii(b, c, d, a, x[i+ 9], 21, -343485551)

    a = safe_add(a, olda)
    b = safe_add(b, oldb)
    c = safe_add(c, oldc)
    d = safe_add(d, oldd)
  }
  return [a, b, c, d]
}

/*
 * Convert an array of little-endian words to a hex string.
 */
function binl2hex(binarray)
{
  var hex_tab = "0123456789abcdef"
  var str = ""
  for(var i = 0; i < binarray.length * 4; i++)
  {
    str += hex_tab.charAt((binarray[i>>2] >> ((i%4)*8+4)) & 0xF) +
           hex_tab.charAt((binarray[i>>2] >> ((i%4)*8)) & 0xF)
  }
  return str
}

/*
 * Convert an array of little-endian words to a base64 encoded string.
 */
function binl2b64(binarray)
{
  var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  var str = ""
  for(var i = 0; i < binarray.length * 32; i += 6)
  {
    str += tab.charAt(((binarray[i>>5] << (i%32)) & 0x3F) |
                      ((binarray[i>>5+1] >> (32-i%32)) & 0x3F))
  }
  return str
}

/*
 * Convert an 8-bit character string to a sequence of 16-word blocks, stored
 * as an array, and append appropriate padding for MD4/5 calculation.
 * If any of the characters are >255, the high byte is silently ignored.
 */
function str2binl(str)
{
  var nblk = ((str.length + 8) >> 6) + 1 // number of 16-word blocks
  var blks = new Array(nblk * 16)
  for(var i = 0; i < nblk * 16; i++) blks[i] = 0
  for(var i = 0; i < str.length; i++)
    blks[i>>2] |= (str.charCodeAt(i) & 0xFF) << ((i%4) * 8)
  blks[i>>2] |= 0x80 << ((i%4) * 8)
  blks[nblk*16-2] = str.length * 8
  return blks
}

function chkpasswd(str)
{
  if (str.length < 8) {
  alert ("Password MUST BE 8+ symbols long!");return;
  }

  return str;
}

function guest(){
//alert ("$__102:visitatore   $__103:visitatore");return;
location.href='$scriptname?mode=demo';
}

function chkemaillength(str)
{
  if (str.length > 64) {
  alert ("Email MUST BE at most 64 symbols long!");return "";
  }

  return str;
}

function chkbadsyms(str)
{
  var tab = "abcdefghijklmnopqrstuvwxyz"
  var good;

  if (str.length > 16) {
  alert ("Login MUST BE at most 16 symbols long!");return "";
  }
  
  if (str.length < 2 ) {
  alert ("Login MUST BE at least 2 symbols long!");return "";
  }
 
  for(var i = 0; i < str.length; i++)
  {
	good = 0;	
	for(var j = 0; j < tab.length; j++)
	{
		if (str.charAt(i) == tab.charAt(j)) 
		{
		good=1;j=tab.length;
		}	
  	}
	
	if (good == 0) {
	        alert("ONLY ANY OF abcdefghijklmnopqrstuvwxyz IN LOGIN !!!"); 
		return "";
	}

  }
  return str;
}

/*
 * Convert a wide-character string to a sequence of 16-word blocks, stored as
 * an array, and append appropriate padding for MD4/5 calculation.
 */
function strw2binl(str)
{
  var nblk = ((str.length + 4) >> 5) + 1 // number of 16-word blocks
  var blks = new Array(nblk * 16)
  for(var i = 0; i < nblk * 16; i++) blks[i] = 0
  for(var i = 0; i < str.length; i++)
    blks[i>>1] |= str.charCodeAt(i) << ((i%2) * 16)
  blks[i>>1] |= 0x80 << ((i%2) * 16)
  blks[nblk*16-2] = str.length * 16
  return blks
}

/*
 * External interface
 */
function hexMD5 (str) { return binl2hex(coreMD5( str2binl(str))) }
function hexMD5w(str) { return binl2hex(coreMD5(strw2binl(str))) }
function b64MD5 (str) { return binl2b64(coreMD5( str2binl(str))) }
function b64MD5w(str) { return binl2b64(coreMD5(strw2binl(str))) }
/* Backward compatibility */
function calcMD5(str) { return binl2hex(coreMD5( str2binl(str))) }

function passCookie(value) {
var curCookie = "Pass=" + escape(value) +"; expires=Sat, 01-Jan-2033 00:00:01 GMT;SameSite=None;Secure;"
document.cookie = curCookie
}

function userCookie(value) {
var curCookie = "User=" + escape(value) +"; expires=Sat, 01-Jan-2033 00:00:01 GMT;SameSite=None;Secure;"
document.cookie = curCookie
}

function graphCookie(value) {
var curCookie = "Graph=" + escape(value) +"; expires=Sat, 01-Jan-2033 00:00:01 GMT;SameSite=None;Secure;"
document.cookie = curCookie
}

function reloadpage(url) {
var yon = window.confirm("$__98");
if (yon) {userCookie('');passCookie('');location.reload();}

}

function graph_reloadpage() {
location.reload();
}

document.cookie = "TestCookie";
if (document.cookie.indexOf("TestCookie") == -1) alert("$__99");

END_OF_JAVASCRIPT

}

sub get_connect_req {

my $ru_en_loco = shift;

my $port	= $primary_port;
my $user  	= $primary_user;
my $passwd	= $primary_passwd;
my $dbase 	= $primary_dbase;
my $server 	= $primary_server;
$hourshift 	= '0 hours';

my $scriptURL = CGI::url();

$scriptURL =~ /^$https:\/\/(.+)\/cgi\//;
my $dom = $1;

return ($dbase,$server,$port,$user,$passwd,$hourshift,$develop);
}

sub xDel {

    local ($element, @in) = @_;
    local (@out);

    foreach $name (@in) {
        push @out, $name unless $element eq $name;
    }
    @out;
}

sub ddos_check {

my $url = shift;

my $checklist = $prefix.'/handlers/checklist';
my $addr=$ENV{'REMOTE_ADDR'};
my $checkstr = $addr."_".$url;
open (IN,$checklist);
   my $counter = 0;
   while (!eof(IN)) {
	my $q = readline (*IN); $q =~ s/\n//g;
	$counter++ if ($q eq $checkstr);
	#my $r = (split('_',$q))[0];
	#$counter++ if ($q =~ /\.php/ && $addr eq $r);
	#print STDERR "Here q is $q and addr is $r!\n" if ($q =~ /\.php/ && $addr eq $r);
   }
   
close (IN);

return $counter;
}

sub apply_firewall {

my $who = shift;

my $applied = 0;

my $addr= length($who) ? $who : $ENV{'REMOTE_ADDR'};

system("sudo /usr/local/bin/ip_apply $addr");
print STDERR "sudo /usr/local/bin/ip_apply $addr\n";

return 1;
}

sub upapply_firewall {

my $who = shift;

my $applied = 0;

my $addr= length($who) ? $who : $ENV{'REMOTE_ADDR'};

system("sudo /usr/local/bin/ip_unapply $addr");
print STDERR "sudo /usr/local/bin/ip_unapply $addr\n";

return 1;
}

sub write_event {
my $who = shift;
my $t = shift;
my $etype = shift;

		my $cmd = "insert into events (player, tbl, p_vremya_z,event_type) values (?,?,current_timestamp,?);";

		my $result=$dbconn->prepare($cmd);

     		$result->execute($who,$t,$etype);
        		&dBaseError($dbconn, $cmd) if (!defined($result));

}

sub write_log_notification {
my $text = shift;

my $messages_log = $prefix.'/handlers/static/messages';

open(OUTFILE, ">>$messages_log");

flock(OUTFILE,LOCK_EX);
select OUTFILE;
print $text."\n";
select(STDOUT);
flock(OUTFILE,LOCK_UN);
close OUTFILE;
}

sub dBaseError {

    my ($check, $message) = @_;
    print "<H4><FONT COLOR=BLACK><P>$message<BR>Error: ".$check->errstr."</FONT></H4>";
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}

sub send_notification {

	my ($email,$mes,$subj) = @_;
	
	
	my $mailprog = '/usr/sbin/sendmail';
	my %Config;
 
	$Config{'message'} =  $mes;
	
	$Config{'recipient'} = $email;

	$Config{'realname'} = "Control Panel";
	$Config{'my_email'} = 'butler';
	
	$Config{'recipient'} =~ s/\s//g;
 
    
    open(MAIL,"|$mailprog -t");

    print MAIL "To: $Config{'recipient'}\n";
    print MAIL "From: $Config{'my_email'} ($Config{'realname'})\n";

    print MAIL "MIME-Version: 1.0\r\n";
    print MAIL "Content-Type: text/plain; $chs\r\n";
    print MAIL "Content-Transfer-Encoding: 8bit\r\n";

    print MAIL "Subject: $subj \n";

    print MAIL $mes."\n";

    close (MAIL);

}

sub get_random {

my $n = shift;

my $chip = substr(md5_hex(time()),16,2);
my $result_of_toss = convert_to_decimal($chip);

return $result_of_toss if (!$n);

return ($result_of_toss-(int($result_of_toss/$n))*$n);
}

sub convert_to_decimal {
my $str = shift;
return hex $str;
}

sub in_array {
my $guy = shift;
my @l  = @_;
foreach my $line (@l) {
return 1 if ($guy eq $line);
}
return 0;
}

1;

package ChicoDigitalLock;

use strict;

use Fcntl qw(:DEFAULT :flock);


my $ALTERNATE_FILE_LOCKING = 1; # set to 1 to enable


sub new {

     my $class = shift;

     my $dir = shift;

     my $flockEnable = shift;

     my $self = bless({ }, $class);

     $self->{dir} = $dir;

     $self->{flockEnabled} = $flockEnable;

     my $lockfile;
     my $lastdir = $dir;

     if ( -d $dir ) { # directory review will create 'review\review.lok'

          if ( substr($dir,-1) ne '/' ) {
                $lastdir =~ s/.*\/(.*?)\Z/$1/;
                $dir .= '/';
          } else {
                $lastdir =~ s/.*\/(.*?)\/\Z/$1/;
          }

          $lockfile = $self->{filename} = $dir . $lastdir . '.lok';

     } else {

          $lockfile = $self->{filename} = $dir . '.lok';
     }

     if ( $flockEnable eq 'yes' ) {

          open(LOCKFILE,">>$lockfile") || return undef;

          # lock exclusive, but allow wait until timeout failure

          if (flock(LOCKFILE, LOCK_EX)==0) { # lock failed if zero

               return undef;
          }

     } else {

          if ( $ALTERNATE_FILE_LOCKING == 1 ) {

               my $count = 0;

               while ( -e $lockfile && $count < 5 ) {

                    $count++;
                    sleep 1;
               }

               if ( $count == 5 ) { errorExit("Unable to open $lockfile<br>\n"); }

               open(LOCKFILE,">$lockfile") or return undef;
          }
     }

     $self->{filehandle} = *LOCKFILE;

     return $self;
}

sub release {

     my $self = shift;

     if ( $self->{flockEnabled} eq 'yes' ) {

          # unlink before closing to prevent race condition

          unlink ( $self->{filename} ); # silently ignore failure

          if ($self->{filehandle}) {

              close( $self->{filehandle} ); # silently ignore failure
          }

     } else {

          if ( $ALTERNATE_FILE_LOCKING == 1 ) {

               if ($self->{filehandle}) {

                   close( $self->{filehandle} );
               }

               unlink ( $self->{filename} );
          }

     }
}

1;
