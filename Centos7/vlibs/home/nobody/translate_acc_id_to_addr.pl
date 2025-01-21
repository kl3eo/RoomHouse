#!/usr/bin/perl
use DBI;

my $server = "127.0.0.1";
my $pguser = "postgres";
my $passwd = "postgres";
my $dbase = "people";
my $port = 5432;

my $dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$pguser, $passwd);

$dbconn->{LongReadLen} = 16384;

$comm = "select accid from now_32877 where addr is null order by baltot, nonce";
my $result=$dbconn->prepare($comm);
$result->execute();
&dBaseError($result, $comm."  (".$result->rows()." rows found)") if ($result->rows() == -2);
my $listresult = $result->fetchall_arrayref;
my $ntuples = $result->rows();

for (my $i = 0; $i < $ntuples; $i++) {
	my $acc = ${${$listresult}[$i]}[0];
	my $res = `node /opt/nvme/polka/translate_addr.js --address=$acc`;
	#print "res is $res!\n";
	$res =~ s/(\r|\n)//g; #5DSSqa6JYQrg9EBwMChRvTXmbfJCGCSEorN7hDAhj7znZYaA
	if ($res =~ /^5[A-z0-9]{47}$/) {
		my $cmd = "update now_32877 set addr = ? where accid = ?";
		my $result = $dbconn->prepare($cmd);
		$result->execute($res, $acc);
		&dBaseError($dbconn, $cmd) if (!defined($result));
	}
}

$dbconn->disconnect;
exit;


sub dBaseError {

    local($check, $message) = @_;
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}
