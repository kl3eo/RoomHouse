#!/usr/bin/perl

use CGI;
use DBI;

my $query = new CGI;
my $par = $query->param('par') || '';

my $server = "127.0.0.1";
my $user = "postgres";
my $passwd = "postgres";
my $dbase = "cp";
my $port = 5432;

$query = new CGI;

my $Coo = $query->cookie('session');

$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$user, $passwd);

$dbconn->{LongReadLen} = 16384;

#cookie null after one page reload
print "Set-Cookie:session = ;Expires = Thu, 01 Jan 1970 00:00:00 GMT;Path = /;SameSite = None;Secure;HttpOnly;\n" if ($par eq '1');

print "Content-type:text/html; charset=UTF-8\r\n\r\n";

$comm = "select acc_id from sessions where session = '$Coo'";

&getTable;

my $acc = $ntuples == 1 ? ${${$listresult}[0]}[0] : '';

print $acc;

$dbconn->disconnect;
exit;

sub getTable { #16

my $now_time  = time;
my $tt = $now_time - $script_start_time;

print STDERR "Debug: in get table - begin, dbase is $dbase; comm is $comm, time is $tt\n" if ($debug);

	$result=$dbconn->prepare($comm);

    	$result->execute;
	&dBaseError($result, $comm."  (".$result->rows()." rows found)") if ($result->rows() ==
	-2);
	
	$listresult = $result->fetchall_arrayref;
	$ntuples = $result->rows();

$now_time  = time;
$tt = $now_time - $script_start_time;

print STDERR "Debug: in get table - end, time is $tt\n" if ($debug);

}

sub dBaseError {

    local($check, $message) = @_;
    print "<H4><FONT COLOR=BLACK><P>$message<BR>Error: ".$check->errstr."</FONT></H4>";
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}
