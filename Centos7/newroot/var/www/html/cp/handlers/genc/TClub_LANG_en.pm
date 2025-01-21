package TClub_LANG_en;
use 5.006;

use strict;
use CGI;

require Exporter;

my $scriptURL = CGI::url();
my $tmm = 0;
$tmm = 1 if ($scriptURL =~ /tennismatchmachine\.com/);
our $scriptURL_tmm = 'http://tennismatchmachine.com/cgi/us_NY/tclub';

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
%lang_list %loco_list %guessed_loco_list @weekday @dtime $language $__69 $__70 $__71 $__71a $__72 $__73 $__73a $__73b $__74 $__75 $__76 $__76a $__76b $__83 $__84 $__84c $__84f
$__84e $__84g $__84h $__88 $__89 $__90 $__91 $__93 $__94a $__96 $__96a $__96b $__97 $__98 $__99 $__99a $__99b $__99bb  $__99k $__99kk 
$__100 $__101 $__102 $__103 $__104 $__105 $__93_1 $__96_1 $__96a_1 $__96b_1 $regbutton $scriptURL_tmm);

our %lang_list = ('ru'=>'Russian',
	      'en'=>'English',
	      'fr'=>'French',
	      'tr'=>'Turkish',
	      'rs'=>'Serbian',
	      'cr'=>'Croatian',
	      'es'=>'Spanish'
);
	      
our %loco_list = ('ru'=>'Moscow',
	      'cat_BCN'=>'El Maresme',
	      'rs_BGR'=>'Belgrade',
	      'ar_BA'=>'Buenos Aires',
	      'tr_IST'=>'Istanbul',
	      'do_DO'=>'Dominicana'
);

our %guessed_loco_list = (
		'ru'=>'Moscow',
	      'cat_BCN'=>'El Maresme',
	      'rs_BGR'=>'Belgrade',
	      'ar_BA'=>'Buenos Aires',
	      'tr_IST'=>'Istanbul',
	      'do_DO'=>'Dominicana'
);


our $language = "english";

our @weekday = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
our @dtime = ('night', 'morning', 'day', 'evening');

our $__69="Hint: Passwords do not match or shorter than 8 symbols!";
our $__70="Hint: Submit login, email and password 8 symbols least!<br>";
our $__71="Hint: Type 4 symbols --  any of 0123456789abcdef";
our $__71a="Hint: Type in the new location name";
our $__72="User with such login already exists!<br>Please submit another login!<br>";
our $__73="<br><div style=\"font-weight:bold;font-size: 14px;\">Registration: Step 1</div><br><small>Please submit a login, a password and your email,<br> and keep your login and password secretly!<br></small>";
our $__73a="<br><br><b>Enter the email you had given during registration:</b><br>";
our $__73b="<br><br><b>Enter your email and the new lounge location:</b><br>";
our $__74="Enter";
our $__75="<small>login:</small>";
our $__76="<small>password:</small>";
our $__76a="<small>Store</small>";
our $__76b="<small>Keep</small>";
our $__83="Login or password incorrect";
our $__84="Register now";
our $__84e="Join lounge in";
our $__84c="Forgot password?";
our $__84f = "Create a new lounge - <font color=#c02233>FREE</font>";
our $__84g = "Check all our lounges - click \"Other\"";
our $__84h = "Not in your city? Look <a style=\"text-decoration:none;\" href=$scriptURL?Submit=Logout><b>here</b></a>!";
our $__88="Click to return";
our $__89="..please wait..";
our $__90="No user name.";
our $__91="No password.";
our $__93="<a href=/docs/contacts_tclub.ru.html target=new><small>Contacts</small></a>";
our $__94a="<a href=/docs/tos.en.html target=new><small>Terms</small></a>";
our $__96="<a href=/docs/about_tclub.ru.html target=new><small>About</small></a>";
our $__96a="<a href=http://www.tennisw.com/forums/blog.php?12525-Build-your-own-tennis-lounge-..-in-your-city target=new><small>What is it?</small></a>";
our $__96b="<a href=javascript:window.guest()><small>Guest view</small></a>";

our $__93_1="<a href=# onclick=\"document.getElementById('Contacts').style.display='block';document.getElementById('About').style.display='none';document.getElementById('Guests').style.display='none';\"><small>Contacts</small></a>";
our $__96_1="This is an online amateur tennis software. Enjoy having most of our code work for you, and only a bit for your opponents!";
our $__96a_1="<a href=# onclick=\"document.getElementById('Contacts').style.display='none';document.getElementById('About').style.display='block';document.getElementById('Guests').style.display='none';\"><small>What is it?</small></a>";
#our $__96b_1="<a href=# onclick=\"document.getElementById('Contacts').style.display='none';document.getElementById('About').style.display='none';document.getElementById('Guests').style.display='block';\"><small>Guest login</small></a>";
our $__96b_1="<a href=$scriptURL?mode=demo><small>Guest login</small></a>";

our $__97="<small>(C) 2006-2013.</small>";
our $__98="Your login and password will not be saved. Are you sure?";
our $__99="You must have Cookies support in your browser on!";
our $__99a="Temporarily out of service";
our $__99b="tennis,lawn tennis,amateur tennis,amateur tennis tournaments,tennis courts,search tennis partner,tennis,tennis how to,online tennis,tennis world,kick serve,cheap tennis balls,tennis forums,tennis forum,tennis lessons,tennis school,tennis camp";
our $__99bb="tennis,lawn tennis,amateur tennis,amateur tennis tournaments,tennis courts,search tennis partner,tennis,tennis how to,online tennis,tennis world,kick serve,cheap tennis balls,tennis forums,tennis forum,tennis lessons,tennis school,tennis camp";

our $__99k="BJON site";
our $__99kk="universally acclaimed BJON site";

our $__100 = "design";
our $__101 = "Javascript must be turned on to work with TClub program!";
our $__102 = "Login";
our $__103 = "Password";
our $__104 = "Other..";
our $__105 = "<a href=\"javascript:writeCookie('MOBILE','1');location.reload();\"><small>PDA version</small></a>";
our $regbutton = "Register";
1;
__END__
