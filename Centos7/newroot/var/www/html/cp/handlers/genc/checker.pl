#!/usr/bin/perl

use CGI;
use DBI;

my $scriptURL = CGI::url();
my $addr = $ENV{'REMOTE_ADDR'};

my $ddositsuko = ddos_check($scriptURL);

my $par = 31;

if ($ddositsuko > $par) {
	exit if ($ddositsuko > $par+1); #important not to apply again
	my $applied = apply_firewall();
	
	if ($applied) {

		print STDERR "$addr: DDOS firewall applied!\n";
	}
}

$query = new CGI;

my $par = $query->param('par') || '';
my $ipaddr = $query->param('addr') || '';

my $Coo = $par eq "session" ? $query->cookie('session') : $query->cookie('role');

my $sess = $query->cookie('session');

#print STDERR "Here addr is $addr, ip is $ipaddr!\n";

#this wouldn't work on Apache proxy of host/domain
if (length($sess) && $ipaddr =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ && $ipaddr eq $addr) {

#if proxy, use:
#if (length($sess) && $ipaddr =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {
	
	my $server = "127.0.0.1";
	my $user = "postgres";
	my $passwd = "postgres";
	my $dbase = "cp";
	my $port = 5432;

	$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$user, $passwd);
	&connError("could not connect to server *** try $scriptname?dbase='aValidDatabaseName' ***") if (!defined($dbconn));

	$dbconn->{LongReadLen} = 16384;
	
	my $cmd = "update sessions set ip = ?, date_and_time=current_timestamp where session = ?";
	my $result = $dbconn->prepare($cmd);
	$result->execute($ipaddr, $sess);
	&dBaseError($dbconn, $cmd) if (!defined($result));
	$dbconn->disconnect;
#print STDERR "in register: setting ip addr to $ipaddr for sess $sess!\n";
}

print "Content-type:text/html; charset=UTF-8\r\n\r\n";
	
print $Coo;

exit;

sub dBaseError {

    local($check, $message) = @_;
    print "<H4><FONT COLOR=BLACK><P>$message<BR>Error: ".$check->errstr."</FONT></H4>";
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}

sub connError { #11

    my $message = shift;
    if (!defined($dbconn)) {print "<H4><FONT COLOR=BLACK><P>$message<BR>Error: ". $DBI::errstr ."</FONT></H4>";die("$message ERROR:$DBI::errstr")}
}

sub ddos_check {

my $url = shift;

my $checklist = "/var/www/html/cp/handlers/checklist";

my $checkstr = $addr."_".$url;
open (IN,$checklist);
   my $counter = 0;
   while (!eof(IN)) {
	my $q = readline (*IN); $q =~ s/\n//g;
	$counter++ if ($q eq $checkstr);
   }
   
close (IN);

return $counter;
}

sub apply_firewall {

my $who = shift;

my $applied = 0;

system("sudo /usr/local/bin/ip_apply $addr");
print STDERR "sudo /usr/local/bin/ip_apply $addr\n";

return 1;
}
