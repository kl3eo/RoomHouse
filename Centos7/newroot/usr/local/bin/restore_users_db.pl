#!/usr/bin/perl

use DBI;

my $debug = 0;

my $server = "127.0.0.1";
my $user = "postgres";
my $passwd = "postgres";
my $dbase = "cp";
my $port = 5432;

$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$user, $passwd);
&connError("could not connect to server *** try $scriptname?dbase='aValidDatabaseName' ***")
	if (!defined($dbconn));

$dbconn->{LongReadLen} = 16384;

  $comm = "select proj_code, pass from members where proj_code != 'admin'";
  &getTable;
  
  for (my $i = 0; $i < $ntuples; $i++) {
  	my $who = ${${$listresult}[$i]}[0];
	my $p = ${${$listresult}[$i]}[1];
	my $res = `/var/www/html/cp/controls/removeUser.pl $who && /var/www/html/cp/controls/addUser.pl $who $p a\@b.com`;
  }
  
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
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}

sub connError { #11

    my $message = shift;
    if (!defined($dbconn)) {print "<H4><FONT COLOR=BLACK><P>$message<BR>Error: ". $DBI::errstr ."</FONT></H4>";die("$message ERROR:$DBI::errstr")}
}
